
camelyon17_path = '/jhcnas3/Pathology/original_data/CAMELYON17/stages.csv'
root = '/jhcnas3/Pathology/Patches/CAMELYON17'
with open(camelyon17_path) as f:
    lines = [l.strip() for l in f]

items = []
normal = 0
tumor = 0
for line in lines:
    slide_id, stage, center = line.split(',')
    if '.tif' in slide_id:
        slide_id = slide_id.split('.')[0]
        # this slide is not avaiable
        if slide_id == 'patient_052_node_1':
            continue
        if 'negative' == stage:
            items.append([root, slide_id, slide_id, 'normal'])
            normal += 1
        else:
            items.append([root, slide_id, slide_id, 'tumor'])
            tumor += 1
print('cam16_normal:', normal)
print('cam16_tumor:', tumor)
normal = 0
tumor = 0

camelyon16_path = '/jhcnas3/Pathology/original_data/CAMELYON16/camelyon16_breast_subset.csv'
with open(camelyon16_path) as f:
    lines = [l.strip() for l in f]

root = '/jhcnas3/Pathology/Patches/CAMELYON16'
for line in lines:
    _, _, slide_id, stage = line.split(',')
    if '.tif' in slide_id:
        slide_id = slide_id.split('.')[0]
        if 'Normal' == stage:
            items.append([root, slide_id, slide_id, 'normal'])
            normal += 1
        else:
            items.append([root, slide_id, slide_id, 'tumor'])
            tumor += 1
print('cam17_normal:', normal)
print('cam17_tumor:', tumor)

import random
random.seed(0)
random.shuffle(items)

with open('camelyon_temps.csv', 'w') as f:
    f.write('dir,case_id,slide_id,label\n')
    for i in items:
        f.write('{},{},{},{}\n'.format(i[0], i[1], i[2], i[3]))