import os
import json
import argparse


parser = argparse.ArgumentParser()
parser.add_argument('--dataset', type=str)
parser.add_argument('--method', type=str, default='linear')


root = '/home/jmabq/data/results'
models = ['resnet50', 'phikon', 'ctranspath', 'uni', 'conch', 'plip', 'distill_87499', 'distill_99999', 'distill_174999', 'distill_12499_cls_only', 'distill_137499_cls_only',
          'distill_12499', 'dinov2_vitl']

Keys = {'resnet50': 'ResNet50', 'ctranspath': 'Ctranspath', 'uni': 'UNI', 
        'conch': 'CONCH', 'plip': 'PLIP', 'distill_87499': 'DisFM-87499',
        'phikon': 'Phikon', 'distill_99999': 'DisFM-99999', 'distill_174999': 'DisFM-174999', 'distill_12499_cls_only':'DisFM-CLS-12499',
        'distill_137499_cls_only': 'DisFM-CLS-137499', 'distill_12499': 'DisFM-12499', 'dinov2_vitl': 'dinov2-vitl'}


def knn_metric(json_path, model_name):
    with open(json_path) as f:
        few_shot = json.loads(f.readline())
        knn = json.loads(f.readline())
    f1_acc_mean = few_shot['full-1']['top1 acc_mean']
    f1_acc_std = few_shot['full-1']['top1 acc_std']
    f1_score_mean = few_shot['full-1']['f1_score_mean']
    f1_score_std = few_shot['full-1']['f1_score_std']
    f20_acc_mean = knn['full-20']['top1 acc_mean']
    f20_acc_std = knn['full-20']['top1 acc_std']
    f20_score_mean = knn['full-20']['f1_score_mean']
    f20_score_std = knn['full-20']['f1_score_std']
    text='{}&{:.3f}±{:.3f}&{:.3f}±{:.3f}&{:.3f}±{:.3f}&{:.3f}±{:.3f} \\\\'.format(
        Keys[model_name], f1_acc_mean, f1_acc_std, f1_score_mean, f1_score_std,
                    f20_acc_mean, f20_acc_std, f20_score_mean, f20_score_std)
    return text

def linear_metric(json_path, model_name):
    with open(json_path) as f:
        for line in f:
            if 'Test result' in line:
                data = line[11:]
    line = json.loads(data)['linear_prob']
    text='{}&{:.3f}±{:.3f}&{:.3f}±{:.3f}&{:.3f}±{:.3f} \\\\'.format(Keys[model_name],
        line['top1 acc_mean'], line['top1 acc_std'], line['f1_score_mean'],
        line['f1_score_std'], line['AUC_mean'], line['AUC_std'],
    )
    return text

if __name__ == '__main__':
    args = parser.parse_args()
    dir = os.path.join(root, args.dataset, args.method)
    for model in models:
        json_path = os.path.join(dir, model, 'results_eval_{}.json'.format(args.method))
        func = knn_metric if args.method == 'knn' else linear_metric
        text = func(json_path, model)
        print(text)

