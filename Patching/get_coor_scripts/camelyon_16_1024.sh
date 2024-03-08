export OPENCV_IO_MAX_IMAGE_PIXELS=10995116277760

save_dir="/storage/Pathology/Patches/CAMELYON16/1024"
source_dir="/jhcnas3/Pathology/original_data/CAMELYON16/WSIs"
wsi_format="tif"
patch_size=1024

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
