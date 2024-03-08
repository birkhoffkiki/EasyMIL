import torch
import torch.nn as nn
import random
import numpy as np
import torch.nn.functional as F
from .mil import BaseMILModel


class softCrossEntropy(nn.Module):
    def __init__(self):
        super(softCrossEntropy, self).__init__()
        return

    def forward(self, inputs, target):
        """
        :param inputs: predictions
        :param target: target labels
        :return: loss
        """
        log_likelihood = - F.log_softmax(inputs, dim=1)
        sample_num, class_num = target.shape
        loss = torch.sum(torch.mul(log_likelihood, target))/sample_num
        return loss


class ABExpert(nn.Module):
    def __init__(self, in_dim, hidden_dim):
        super().__init__()
        self.attention = nn.Sequential(nn.Linear(in_dim, hidden_dim), nn.Tanh(), nn.Linear(hidden_dim, 1))

    def forward(self, x) -> torch.Tensor:
        UA = self.attention(x)
        UA = torch.transpose(UA, -1, -2)  # KxN
        UA = F.softmax(UA, dim=-1)  # softmax over N
        UM = torch.mm(UA, x)  # KxL
        return UM


class MoeLayer(nn.Module):
    def __init__(self, feature_dim, hidden_dim, experts_num):
        super().__init__()
        self.experts_num = experts_num
        self.feature_dim = feature_dim
        self.num_experts_per_tok = 1
        self.experts = nn.ModuleList([ABExpert(feature_dim, hidden_dim) for _ in range(experts_num)])
        self.gate = nn.Linear(feature_dim, experts_num, bias=False)

    def forward(self, inputs: torch.Tensor):
        gate_logits = self.gate(inputs)
        weights, selected_experts = torch.topk(gate_logits, self.num_experts_per_tok)
        weights = F.softmax(weights, dim=1, dtype=torch.float).to(inputs.dtype)
        results = []
        for i, expert in enumerate(self.experts):
            batch_idx, nth_expert = torch.where(selected_experts == i)
            results.append(expert(inputs[batch_idx]))
        results = torch.cat(results, dim=1)
        return results


class MoE(BaseMILModel):
    def __init__(self, in_dim=1024, n_classes=1, act='gelu', task='subtyping',
                 samples_per_cls=None, noise_std=0.1):
        super(MoE, self).__init__(task=task)
        self.L = 512
        self.D = 128
        self.K = 1
        self.experts_num = 8
        self.n_classes = n_classes
        self.noise_std = noise_std
        self.samples_per_cls = samples_per_cls
        
        self.cut_flag = False
        self.task_type = task
            
        act_fun = nn.GELU if act == 'gelu' else nn.ReLU
        dropout_p = 0.2

        if not isinstance(in_dim, (list, tuple)):
            raise ValueError('The in_dim should be a list')

        self.feature = nn.ModuleList()
        for idm in in_dim:
            self.feature.append(nn.Sequential(nn.Linear(idm, self.L), act_fun(), nn.Dropout(dropout_p)))

        self.moe = MoeLayer(self.L, self.D, 2)
        
        # self.attention = nn.Sequential(nn.Linear(self.L, self.D), nn.Tanh(), nn.Linear(self.D, self.K))
        
        self.union_classifier = nn.Linear(self.L*2, n_classes+1)
        if task == 'subtyping':
            self.loss_fn = nn.CrossEntropyLoss()
        elif task == 'survival':
            from utils.survival_utils import NLLSurvLoss
            self.loss_fn = NLLSurvLoss(alpha=0.0)
        
        self.memory_bank = {i:[] for i in range(n_classes)}
            
    def set_up(self, lr, max_epochs, weight_decay, **args):
        params = filter(lambda p: p.requires_grad, self.parameters())
        self.opt_wsi = torch.optim.Adam(params, lr=lr,  weight_decay=weight_decay*10)
    
    def process_data(self, data, label, device):
        data = [i.to(device) for i in data]
        label = label.to(device)
        return data, label

    def cut_pair(self, data):
        d1, d2 = data
        perm = torch.randperm(d1.shape[0])
        ratio1 = 1 - random.random()*0.3
        half1 = int(d1.shape[0]*ratio1)
        ratio2 = 1 - random.random()*0.3
        half2 = int(d1.shape[0]*ratio2)
        d1 = d1[perm][:half1, :]
        d2 = d2[perm][:half2, :]
        return [d1, d2]
    
    def one_step(self, data, label, **args):
                
        if self.cut_flag and random.random() > 0.5:
            data = self.cut_pair(data)
                
        if len(self.samples_per_cls) == 2:
            p = 0.1
        else:
            p = 1/(self.n_classes + 1)
        
        augmentation = random.random() < p if self.task_type == 'sutyping' else False
        if augmentation:
            noise_counter = 0
            for index, d in enumerate(data):
                mean = (random.random() - 0.5)*2
                std = random.random()*self.noise_std
                noise = torch.normal(mean, std, d.shape, device=d.device)
                if random.random() > 0.5:
                    data[index] = d + noise
                    noise_counter += 1
            if noise_counter == 2:
                label = label - label + self.n_classes
                
        outputs = self.forward(data, augmentation=augmentation)
        logits = outputs['wsi_logits']
        
        if self.task_type == 'subtyping':
            loss = self.loss_fn(logits, label)
        elif self.task_type == 'survival':
            hazards, S, _ = outputs['wsi_logits'], outputs['wsi_prob'], outputs['wsi_label']
            c = args['c']
            loss = self.loss_fn(hazards=hazards, S=S, Y=label, c=c)
        else:
            raise NotImplementedError
        
        self.opt_wsi.zero_grad()
        loss.backward()
        self.opt_wsi.step()
        outputs['loss'] = loss
        return outputs

    def forward(self, x, augmentation=False):
        # feat fn
        features = []
        for fn, i in zip(self.feature, x):
            feature = fn(i)
            features.append(feature)
            
        UM = torch.cat(features, dim=0)
        UM = self.moe(UM)
        # UA = self.attention(UM)
        # UA = torch.transpose(UA, -1, -2)  # KxN
        # UA = F.softmax(UA, dim=-1)  # softmax over N
        # UM = torch.mm(UA, UM)  # KxLk
        
        logits = self.union_classifier(UM)
        wsi_logits, wsi_prob, wsi_label = self.task_adapter(logits)
        
        outputs = {
            'wsi_logits': wsi_logits,
            'wsi_prob': wsi_prob,
            'wsi_label': wsi_label,
            'features': features,
        }
        return outputs
        
    def wsi_predict(self, x, **args):
        features = []
        for fn, i in zip(self.feature, x):
            feature = fn(i)
            features.append(feature)
            
        UM = torch.cat(features, dim=0)
        UM = self.moe(UM)
        # UA = self.attention(UM)
        # UA = torch.transpose(UA, -1, -2)  # KxN
        # UA = F.softmax(UA, dim=-1)  # softmax over N
        # UM = torch.mm(UA, UM)  # KxL
        
        logits = self.union_classifier(UM)[:, :self.n_classes]
        wsi_logits, wsi_prob, wsi_label = self.task_adapter(logits)
        
        outputs = {
            'wsi_logits': wsi_logits,
            'wsi_prob': wsi_prob,
            'wsi_label': wsi_label,
            'features': features,
        }
        return outputs

