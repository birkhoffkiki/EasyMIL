export OPENCV_IO_MAX_IMAGE_PIXELS=10995116277760

save_dir="/storage/Pathology/Patches/RCC-DHMC"
source_dir="/jhcnas3/Pathology/original_data/RCC-DHMC"
wsi_format="png"
patch_size=512

nohup python create_patches_all.py \
        --source $source_dir \
        --save_dir $save_dir\
        --patch_size $patch_size \
        --redudant 0 \
        --wsi_format $wsi_format > "DHMC.log" 2>&1 &
