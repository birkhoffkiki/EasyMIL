root = {
    'KICH': '/jhcnas3/Pathology/Patches/TCGA__KICH',
    }

save_path = './KICH.csv'


if __name__ == '__main__':
    import os
    handle = open(save_path, 'w')
    handle.write('dir,case_id,slide_id,label\n')
    for k, v in root.items():
        files = os.listdir(os.path.join(v, 'patches'))
        files = [f[:-3] for f in files]
        for f in files:
            line = '{},{},{},{}\n'.format(v,f, f, k)
            handle.write(line)
    handle.close()