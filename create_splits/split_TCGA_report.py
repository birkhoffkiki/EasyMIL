import random
import os
random.seed(0)

train = 0.7
val = 0.1
test = 0.2

save_path = '/storage/Pathology/codes/EasyMIL/splits712/TCGA-Report'
if not os.path.exists(save_path):
    os.makedirs(save_path)

with open('dataset_csv/case_id_wsi_report_single_wsi.csv') as f:
    data_items = []
    for line in f:
        line = line.strip().split(',')[-1]
        data_items.append(line)
    data_items = data_items[1:]

random.shuffle(data_items)

train_num = int(len(data_items)*train)
val_num = int(len(data_items)*val)

train_items = data_items[:train_num]
val_items = data_items[train_num:train_num+val_num]
test_items = data_items[train_num+val_num:]
print('Train items:', len(train_items))
print('Val items:', len(val_items))
print('Test items:', len(test_items))


with open(os.path.join(save_path, 'splits_0_bool.csv'), 'w') as f:
    f.write(',train,val,test\n')
    for item in train_items:
        f.write(f'{item},True,False,False\n')
    for item in val_items:
        f.write(f'{item},False,True,False\n')
    for item in test_items:
        f.write(f'{item},False,False,True\n')
        

with open(os.path.join(save_path, 'splits_0.csv'), 'w') as f:
    f.write(',train,val,test\n')
    counter = 0
    for _ in range(val_num):
        f.write(f'{counter},{train_items.pop()},{val_items.pop()},{test_items.pop()}\n')
        counter += 1
    for _ in range(len(test_items)):
        f.write(f'{counter},{train_items.pop()},,{test_items.pop()}\n')
        counter += 1
    for _ in range(len(train_items)):
        f.write(f'{counter},{train_items.pop()},,\n')
        counter += 1
        
    





