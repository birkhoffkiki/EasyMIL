
save_path = './PANDA.csv'
label_csv = '/jhcnas3/Pathology/original_data/PANDA/train.csv'
h5_root = '/storage/Pathology/Patches/PANDA/patches'

v = '/storage/Pathology/Patches/PANDA'


if __name__ == '__main__':
    import os
    import random
    random.seed(0)
    
    data_items = []
    with open(label_csv) as f:
        for line in f:
            slide_id, center, isup, g_score = line.strip().split(',')
            p = os.path.join(h5_root, slide_id+'.h5')
            if os.path.exists(p):
                data_items.append([slide_id, isup])
    
    random.shuffle(data_items)
    
    handle = open(save_path, 'w')
    handle.write('dir,case_id,slide_id,label\n')
    for sid, isup in data_items:
        line = '{},{},{},{}\n'.format(v,sid, sid, isup)
        handle.write(line)
    handle.close()