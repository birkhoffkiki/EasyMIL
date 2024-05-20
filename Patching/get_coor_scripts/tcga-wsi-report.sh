export OPENCV_IO_MAX_IMAGE_PIXELS=10995116277760

# item="Ovarian_Bevacizumab_Response"
# source_dir="/jhcnas3/Pathology/original_data/Ovarian_Bevacizumab_Response"
source_dir="/jhcnas3/Pathology/original_data/wsi-report/slides"
wsi_format="svs"

patch_size=512
# save_dir="/storage/Pathology/Patches/"$item
save_dir="/storage/Pathology/wsi-report/wsi4report"
python create_patches_fp.py \
    --source $source_dir \
    --save_dir $save_dir\
    --preset tcga.csv \
    --patch_level 0 \
    --patch_size $patch_size \
    --step_size $patch_size \
    --wsi_format $wsi_format \
    --seg \
    --patch \
    --stitch 
