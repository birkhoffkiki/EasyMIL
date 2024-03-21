import os
import argparse

meta = {
    'NSCLC': ['/storage/Pathology/Patches/TCGA__LUAD/pt_files', '/storage/Pathology/Patches/TCGA__LUSC/pt_files'],
    'CAMELYON': ['/storage/Pathology/Patches/CAMELYON16/pt_files', '/storage/Pathology/Patches/CAMELYON17/pt_files'],
    'RCC': ['/storage/Pathology/Patches/TCGA__KIRP/pt_files', '/storage/Pathology/Patches/TCGA__KIRC/pt_files', '/storage/Pathology/Patches/TCGA__KICH/pt_files'],
    'PANDA': ['/storage/Pathology/Patches/PANDA/pt_files'],
    'BRCA': ['/storage/Pathology/Patches/TCGA__BRCA/pt_files'],
    'BRACS': ['/storage/Pathology/Patches/BRACS/pt_files'],
    'TUPAC': ['/storage/Pathology/Patches/TUPAC16/pt_files'],
    'UBC-OCEAN': ['/storage/Pathology/Patches/UBC-OCEAN/pt_files'],
    'STAD': ['/storage/Pathology/Patches/TCGA__STAD/pt_files'],
    'COADREAD': ['/storage/Pathology/Patches/TCGA__COADREAD/pt_files']
    
}

def print_feature_info(data_lists):
    for root in data_lists:
        print('*', root)
        models = os.listdir(root)
        for m in models:
            p = os.path.join(root, m)
            slides = os.listdir(p)
            print('\t{}:{}'.format(m, len(slides)))
            
    

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--name', type=str, default='')
    
    args = parser.parse_args()
    
    print_feature_info(meta[args.name])
    
    