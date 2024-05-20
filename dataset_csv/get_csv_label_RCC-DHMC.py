
save_path = './RCC-DHMC.csv'


if __name__ == '__main__':
    import os

    root = '/jhcnas3/Pathology/original_data/RCC-DHMC'
    handle = open(save_path, 'w')
    handle.write('dir,case_id,slide_id,label\n')
    classes = os.listdir(root)
    items = [i for i in classes if os.path.isdir(os.path.join(root, i))]
    
    for item in items:
        dir = os.path.join(root, item)
        names = os.listdir(dir)
        for name in names:
            slide_id = name.split('.')[0]
            line = '{},{},{},{}\n'.format('/storage/Pathology/Patches/RCC-DHMC',slide_id, slide_id, item)
            handle.write(line)
    handle.close()
    print('Done')