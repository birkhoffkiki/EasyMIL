import json
import os


excluded_list = []
total_slides = 0

split_root = 'splits712'
save_exclude_file_path = os.path.join(split_root, 'exclude_list.csv')

datasets = os.listdir(split_root)

for data in datasets:
    csv_file = os.path.join(split_root, data, 'splits_0_bool.csv')
    with open(csv_file) as f:
        slides = f.readlines()
        slides = [r.strip().split(',') for r in slides[1:]]
    total_slides += len(slides)
    for s in slides:
        if 'True' in s[2:]:
            excluded_list.append(s[0])

print('Exluded files number:', len(excluded_list))
print('Total files:', total_slides)
print('ratio:', len(excluded_list)/total_slides)

with open(save_exclude_file_path, 'w') as f:
    for line in excluded_list:
        f.write('{}\n'.format(line))
    
    