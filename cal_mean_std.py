import pandas as pd
import numpy as np
import os
import argparse


def mean_std(path):
    df = pd.read_csv(path)
    auc = np.array(df['test_auc'])
    acc = np.array(df['test_acc'])
    f1 = np.array(df['test_f1'])
    
    auc_mean = np.mean(auc)
    auc_std = np.std(auc)
    
    acc_mean = np.mean(acc)
    acc_std = np.std(acc)
    
    f1_mean = np.mean(f1)
    f1_std = np.std(f1)
    
    prefix, _ = os.path.split(path)
    new_path = os.path.join(prefix, 'mean_std.txt')
    with open(new_path, 'w') as f:
        f.write('AUC mean: {:.3f}\n'.format(auc_mean))
        f.write('AUC std: {:.3f}\n'.format(auc_std))
    
        f.write('ACC mean: {:.3f}\n'.format(acc_mean))
        f.write('ACC std: {:.3f}\n'.format(acc_std))
        
        f.write('F1 mean: {:.3f}\n'.format(f1_mean))
        f.write('F1 std: {:.3f}\n'.format(f1_std))


def mean_std_survival(path):
    df = pd.read_csv(path)
    auc = np.array(df['test_cindex'])
    
    auc_mean = np.mean(auc)
    auc_std = np.std(auc)
    
    prefix, _ = os.path.split(path)
    try:
        new_path = os.path.join(prefix, 'mean_std.txt')
        with open(new_path, 'w') as f:
            f.write('C-index mean: {:.3f}\n'.format(auc_mean))
            f.write('C-index std: {:.3f}\n'.format(auc_std))
    except:
        print('Faied to write:')
        print('C-index mean: {:.3f}\n'.format(auc_mean))
        print('C-index std: {:.3f}\n'.format(auc_std))
        
    


parser = argparse.ArgumentParser()
parser.add_argument('--file_path')
parser.add_argument('--type', default='auc')


if __name__ == '__main__':
    args = parser.parse_args()
    if args.type == 'auc':
        mean_std(args.file_path)
    else:
        mean_std_survival(args.file_path)