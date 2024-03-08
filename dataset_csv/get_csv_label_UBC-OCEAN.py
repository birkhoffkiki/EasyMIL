
save_path = './UBC-OCEAN.csv'


if __name__ == '__main__':
    import os
    with open('/jhcnas3/Pathology/original_data/UBC-OCEAN/train.csv') as f:
        items = [line.strip() for line in f]
    v =  '/storage/Pathology/Patches/UBC-OCEAN'
    handle = open(save_path, 'w')
    handle.write('dir,case_id,slide_id,label\n')
    all_labels = []
    for item in items:
        k = item.split(',')

        slide_id = k[0]
        if os.path.exists(os.path.join('/storage/Pathology/Patches/UBC-OCEAN/patches', f'{slide_id}.h5')):
            label = k[1]
            all_labels.append(label)
            line = '{},{},{},{}\n'.format(v,slide_id, slide_id, label)
            handle.write(line)
    handle.close()
    
    print('label num:', len(set(all_labels)))
    print(set(all_labels))