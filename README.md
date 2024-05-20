# A Toolkit for Pathology Image Analysis

# Step 1: Patching
Crop patches from WSI.
```bash
cd Patching
# segment the tissue and get the coors
bash get_coor_scripts/CPTAC.sh
# crop patches from WSI if need
bash crop_image_scripts/CPTAC.sh
```
# Step 2: Extracting features
```bash
cd ..
bash extract_scripts/CPTAC.sh
```
# Step 3: xxx