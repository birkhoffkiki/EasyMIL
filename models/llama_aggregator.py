import torch
import torch.nn as nn
import torch.nn.functional as F
from transformers import AutoConfig, AutoModelForCausalLM, \
                         LlamaConfig, LlamaModel, LlamaForCausalLM

from transformers.modeling_outputs import CausalLMOutputWithPast
from torch.distributed import barrier 
from typing import List, Optional, Tuple, Union

class WSI_Expert_Config(LlamaConfig):
    model_type = "WSI_Expert"

class WSILlamaModel(LlamaModel):
    config_class = WSI_Expert_Config
    
    def __init__(self, config: LlamaConfig):
        super(WSILlamaModel, self).__init__(config)
        
#! Use with conda env longlora-ori
class WSI_Expert_Llama_Ori(LlamaForCausalLM):
    config_class = WSI_Expert_Config
    
    def __init__(self, config = LlamaConfig(_flash_attn_2_enabled = True), n_classes = 3,  survival = False):
        super(LlamaForCausalLM, self).__init__(config)  # Correctly initialize the superclass 
        # self.model_path = "/storage/Pathology/codes/LongLoRA/fine_tune_output/84866wsi-16k-2000steps-merged-copy"
        # self.model = WSILlamaModel(config).from_pretrained(self.model_path)
        self.model = WSILlamaModel(config)
        self.dino = nn.Linear(1024, 4096)
        self.back_to_dino = nn.Linear(4096, 1024)
        self.n_classes = n_classes
        self.score = nn.Linear(1024, self.n_classes, bias=False)
        self.survival = survival
        
        self.pretraining_tp = config.pretraining_tp
        self.vocab_size = config.vocab_size
        self.lm_head = nn.Linear(config.hidden_size, config.vocab_size, bias=False)
        self.post_init()
        
        # for name, param in self.model.named_parameters():
        #     if 'score' not in name and 'dino' not in name:
        #         param.requires_grad = False
        
    def get_model(self):
        return self.model
    
    def find_seq_length(self, inputs_embeds, pad_value=-100):
        # Find the tensors that are all -100
        mask = inputs_embeds.eq(pad_value).all(dim=-1)
        # Find the first all -100 tensor in each sequence
        seq_lengths = mask.size(1) - mask.flip([1]).cumsum(dim=-1).flip([1]).argmax(dim=-1) - 1
        return seq_lengths
    
    def forward(self, inputs_embeds=None, **kwargs):
        inputs_embeds = inputs_embeds.unsqueeze(0)
        inputs_embeds = self.dino(inputs_embeds)
        
        outputs = self.model(input_ids = None, inputs_embeds = inputs_embeds, **kwargs)
        hidden_states = outputs[0]
        # Get the last hidden state
        logits_1024 = self.back_to_dino(hidden_states)
        # Pass through the new layer
        logits = self.score(logits_1024)
        #! .half()
        logits = logits.bfloat16()
        
        batch_size = inputs_embeds.shape[0]
        sequence_lengths = self.find_seq_length(inputs_embeds)
        pooled_logits = logits[torch.arange(batch_size, device=logits.device), sequence_lengths]
        
        '''
        Survival layer
        '''
        if self.survival:
            Y_hat = torch.topk(pooled_logits, 1, dim = 1)[1]
            hazards = torch.sigmoid(pooled_logits)
            S = torch.cumprod(1 - hazards, dim=1)
            return hazards, S, Y_hat, None, None 
        
        Y_prob = F.softmax(pooled_logits, dim=1)
        Y_hat = torch.topk(pooled_logits, 1, dim=1)[1]
    
        return pooled_logits, Y_prob, Y_hat, None, None
    
AutoConfig.register("WSI_Expert", WSI_Expert_Config)
AutoModelForCausalLM.register(WSI_Expert_Config, WSI_Expert_Llama_Ori)


#! Use with conda env longlora-clam        
class WSI_Expert_Llama(LlamaForCausalLM):
    config_class = WSI_Expert_Config
    
    def __init__(self, config = LlamaConfig(), n_classes = 2, survival = False):
        super(LlamaForCausalLM, self).__init__(config)  # Correctly initialize the superclass
        self.model_path = "/storage/Pathology/codes/LongLoRA/fine_tune_output/84866wsi-16k-2000steps-merged-copy"
        self.model = WSILlamaModel(config).from_pretrained(self.model_path)
        self.score = nn.Linear(1024, n_classes, bias=False)
        self.survival = survival
        
        self.pretraining_tp = config.pretraining_tp
        self.vocab_size = config.vocab_size
        self.lm_head = nn.Linear(config.hidden_size, config.vocab_size, bias=False)
        self.post_init()
        
        # for name, param in self.model.named_parameters():
        #     if 'score' not in name:
        #         param.requires_grad = False
        
    def get_model(self):
        return self.model
    
    def find_seq_length(self, inputs_embeds, pad_value=-100):
        # Find the tensors that are all -100
        mask = inputs_embeds.eq(pad_value).all(dim=-1)
        # Find the first all -100 tensor in each sequence
        seq_lengths = mask.size(1) - mask.flip([1]).cumsum(dim=-1).flip([1]).argmax(dim=-1) - 1
        return seq_lengths
    
    def forward(self, inputs_embeds=None, **kwargs):
        
        inputs_embeds = inputs_embeds.unsqueeze(0)
        outputs = super().forward(input_ids = None, inputs_embeds = inputs_embeds, **kwargs)

        # Get the last hidden state
        logits_1024 = outputs[1]
        # Pass through the new layer
        logits = self.score(logits_1024)
        
        batch_size = inputs_embeds.shape[0]
        sequence_lengths = self.find_seq_length(inputs_embeds)
        pooled_logits = logits[torch.arange(batch_size, device=logits.device), sequence_lengths]
        
        '''
        Survival layer
        '''
        if self.survival:
            Y_hat = torch.topk(pooled_logits, 1, dim = 1)[1]
            hazards = torch.sigmoid(pooled_logits)
            S = torch.cumprod(1 - hazards, dim=1)
            return hazards, S, Y_hat, None, None 
        
        Y_prob = F.softmax(pooled_logits, dim=1)
        Y_hat = torch.topk(pooled_logits, 1, dim=1)[1]
    
        return pooled_logits, Y_prob, Y_hat, None, None
    
AutoConfig.register("WSI_Expert", WSI_Expert_Config)
AutoModelForCausalLM.register(WSI_Expert_Config, WSI_Expert_Llama)


# class WSI_Expert(LlamaForCausalLM):
#     def __init__(self, config = LlamaConfig(), model_path = '/storage/Pathology/codes/LongLoRA/fine_tune_output/84866wsi-16k-2000steps-merged', n_classes = 2, survival = False):
#         super().__init__(config)
        
#         # Load pre-trained model
#         self.base_model = LlamaForCausalLM.from_pretrained(model_path)
        
#         for name, param in self.base_model.named_parameters():
#             # if "dino" not in name:
#             param.requires_grad = False
        
#         # Add more layers
#         self.head = nn.Linear(1024, n_classes, bias=False)
#         self.survival = survival
        
#         self.post_init()
        
#     def get_model(self):
#         return self.base_model
        
#     def find_seq_length(self, inputs_embeds, pad_value=-100):
#         # Find the tensors that are all -100
#         mask = inputs_embeds.eq(pad_value).all(dim=-1)
#         # Find the first all -100 tensor in each sequence
#         seq_lengths = mask.size(1) - mask.flip([1]).cumsum(dim=-1).flip([1]).argmax(dim=-1) - 1
#         return seq_lengths
        
#     def forward(self, inputs_embeds=None, **kwargs):
        
#         outputs = self.base_model(inputs_embeds = inputs_embeds, **kwargs)
#         # Get the last hidden state
#         logits_1024 = outputs[1]
#         # Pass through the new layer
#         logits = self.head(logits_1024)
        
#         batch_size = inputs_embeds.shape[0]
#         sequence_lengths = self.find_seq_length(inputs_embeds)
#         pooled_logits = logits[torch.arange(batch_size, device=logits.device), sequence_lengths]
        
#         '''
#         Survival layer
#         '''
#         if self.survival:
#             Y_hat = torch.topk(pooled_logits, 1, dim = 1)[1]
#             hazards = torch.sigmoid(pooled_logits)
#             S = torch.cumprod(1 - hazards, dim=1)
#             return hazards, S, Y_hat, None, None 
        
#         Y_prob = F.softmax(pooled_logits, dim=1)
#         Y_hat = torch.topk(pooled_logits, 1, dim=1)[1]

#         return logits, Y_prob, Y_hat, None, None