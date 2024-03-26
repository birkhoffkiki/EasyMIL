save_path = './COAD_READ_molecular_subtyping.csv'

if __name__ == '__main__':
    import os
    with open('/jhcnas3/Pathology/original_data/TCGA/COAD/cms_labels_public_all.txt') as f:
        items = [line.strip().split('\t') for line in f]
    v =  ['/jhcnas3/Pathology/Patches/TCGA__COAD/', '/jhcnas3/Pathology/Patches/TCGA__READ/']
    files = []
    for vv in v:
        files += os.listdir(os.path.join(vv, 'patches'))
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
        if os.path.exists(os.path.join('/jhcnas3/Pathology/Patches/TCGA__READ/patches', f'{slide_id}.h5')) or os.path.exists(os.path.join('/jhcnas3/Pathology/Patches/TCGA__COAD/patches', f'{slide_id}.h5')):
            if os.path.exists(os.path.join('/jhcnas3/Pathology/Patches/TCGA__COAD/patches', f'{slide_id}.h5')):
                v = '/jhcnas3/Pathology/Patches/TCGA__COAD/'
            elif os.path.exists(os.path.join('/jhcnas3/Pathology/Patches/TCGA__READ/patches', f'{slide_id}.h5')):
                v = '/jhcnas3/Pathology/Patches/TCGA__READ/'
            label = item[4]
            if label == 'NOLBL':
                continue
            all_labels.append(label)
            line = '{},{},{},{}\n'.format(v,slide_id, slide_id, label)
            handle.write(line)
    handle.close()
    
    print('label num:', len(set(all_labels)))
    print(set(all_labels))