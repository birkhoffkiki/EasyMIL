save_path = './BRCA_molecular_subtyping.csv'

if __name__ == '__main__':
    import os
    with open('/jhcnas3/Pathology/original_data/TCGA/BRCA/BRCA.547.PAM50.SigClust.Subtypes.txt') as f:
        items = [line.strip().split('\t') for line in f]
    v =  '/jhcnas3/Pathology/Patches/TCGA__BRCA/'
    files = os.listdir(os.path.join(v, 'patches'))
    files = [f[:-3] for f in files]
    handle = open(save_path, 'w')
    handle.write('dir,case_id,slide_id,label\n')
    all_labels = []
    for item in items:
        txt_id = '-'.join(item[0].split('-')[:3])
        for f in files:
            if txt_id in f:
                slide_id = f
                break
            else:
                slide_id = None
        if slide_id is None:
            continue
        if os.path.exists(os.path.join('/jhcnas3/Pathology/Patches/TCGA__BRCA/patches', f'{slide_id}.h5')):
            label = item[3]
            all_labels.append(label)
            line = '{},{},{},{}\n'.format(v,slide_id, slide_id, label)
            handle.write(line)
    handle.close()
    
    print('label num:', len(set(all_labels)))
    print(set(all_labels))