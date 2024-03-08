import pandas as pd

save_path = './BRACS.csv'

data = pd.read_excel('/storage/Pathology/codes/CLAM/dataset_csv/BRACS.xlsx')
wsi_filenames = data['WSI Filename']
wsi_labels = data['WSI label']
wsi_set = data['Set']

h5_root = '/storage/Pathology/Patches/BRACS/patches'

v = '/storage/Pathology/Patches/BRACS'


if __name__ == '__main__':
    import os
    import random
    
    data_items = {'Training': [], 'Testing': [], 'Validation': []}
    
    for f, l, s in zip(wsi_filenames, wsi_labels, wsi_set):
        p = os.path.join(h5_root, f+'.h5')
        if not os.path.exists(p):
            print('{} not exists, {}, {}'.format(f, l, s))
            continue
        data_items[s].append([v, f, f, l])
    print()
    handle = open(save_path, 'w')
    handle.write('dir,case_id,slide_id,label\n')
    for k, subs in data_items.items():
        for sid in subs:
            line = '{},{},{},{}\n'.format(sid[0], sid[1], sid[2], sid[3])
            handle.write(line)
    handle.close()

    # # write splits
    # with open('/storage/Pathology/codes/CLAM/splits/BRACS/splits_0_bool.csv', 'w') as f:
    #     f.write(',train,val,test\n')
    #     for k, subs in data_items.items():
    #         for item in subs:
    #             item = item[1]
    #             if k == 'Training':
    #                 text = '{},True,False,False'.format(item)
    #             elif k == 'Testing':
    #                 text = '{},False,False,True'.format(item)
    #             elif k == 'Validation':
    #                 text = '{},False,True,False'.format(item)
    #             else:
    #                 raise RuntimeError
    #             f.write(f'{text}\n')
    
    # # write descriptor
    # with open('/storage/Pathology/codes/CLAM/splits/BRACS/splits_0.csv', 'w') as f:
    #     f.write(',train,val,test\n')
        
    #     train = data_items['Training']
    #     test = data_items['Testing']
    #     val = data_items['Validation']
    #     for index in range(len(train)):
    #         string = '{},{}'.format(index, train[index][1])
    #         if index < len(val):
    #             string = string + ',' + val[index][1]
    #         if index < len(test):
    #             string = string + ',' + test[index][1]
    #         f.write('{}\n'.format(string))
            
            
        
        
                    