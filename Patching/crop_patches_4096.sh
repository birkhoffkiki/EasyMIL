export OPENCV_IO_MAX_IMAGE_PIXELS=10995116277760

# # TCGA
arr[0]="BRCA"
# arr[0]="COAD"
# arr[0]="LUAD"
# arr[0]="STAD"
# arr[0]="KIRP"
# arr[0]="KIRC"
# arr[0]="READ"

# # configuration
datatype="tcga"
wsi_format="svs"
level=1
size=4096
cpu_cores=24
h5_root="/jhcnas3/Pathology/Patches/TCGA__"
save_root="/jhcnas3/Pathology/Patches/TCGA__"
wsi_root="/jhcnas2/home/zhoufengtao/data/TCGA/TCGA-"

# #Array Loop  
for i in "${!arr[@]}" 
do  
subtype="${arr[$i]}"
echo Processing $subtype
h5_r="$h5_root$subtype""/4096/patches"; echo $h5_r
s_r="$save_root$subtype""/4096/images"; echo $s_r
w_r="$wsi_root$subtype""/slides"; echo $w_r
python extract_images.py \
        --datatype $datatype \
        --wsi_format $wsi_format \
        --level $level \
        --size $size \
        --cpu_cores $cpu_cores \
        --h5_root $h5_r \
        --save_root $s_r \
        --wsi_root $w_r
done


# # BACH
# export OPENCV_IO_MAX_IMAGE_PIXELS=10995116277760
# # configuration
# datatype="tcga"
# wsi_format="svs"
# level=0
# size=512
# cpu_cores=96
# h5_root="/jhcnas3/Pathology/Patches/TCGA-forzen2/patches"
# save_root="/jhcnas3/Pathology/Patches/TCGA-forzen2/images"
# wsi_root="/jhcnas3/Pathology/original_data/TCGA-forzen2"

# #Array Loop  
# python extract_images.py \
#         --datatype $datatype \
#         --wsi_format $wsi_format \
#         --level $level \
#         --cpu_cores $cpu_cores \
#         --h5_root $h5_root \
#         --save_root $save_root \
#         --wsi_root $wsi_root

# # AGGC2022
# export OPENCV_IO_MAX_IMAGE_PIXELS=10995116277760
# # configuration
# datatype="single_folder"
# wsi_format="tiff"
# level=0
# size=512
# cpu_cores=48
# h5_root="/jhcnas3/Pathology/Patches/AGGC2022/patches"
# save_root="/jhcnas3/Pathology/Patches/AGGC2022/images"
# wsi_root="/home/jmabq/temp/WSI"

# #Array Loop  
# python extract_images.py \
#         --datatype $datatype \
#         --wsi_format $wsi_format \
#         --level $level \
#         --cpu_cores $cpu_cores \
#         --h5_root $h5_root \
#         --save_root $save_root \
#         --wsi_root $wsi_root

# # BCNB #TODO, not croped yet
# export OPENCV_IO_MAX_IMAGE_PIXELS=10995116277760
# # configuration
# datatype="single_folder"
# wsi_format="jpg"
# level=0
# size=512
# cpu_cores=24
# h5_root="/jhcnas3/Pathology/Patches/BCNB/patches"
# save_root="/jhcnas3/Pathology/Patches/BCNB/images"
# wsi_root="/jhcnas3/Pathology/original_data/BCNB/WSIs"

# #Array Loop  
# python extract_images.py \
#         --datatype $datatype \
#         --wsi_format $wsi_format \
#         --level $level \
#         --cpu_cores $cpu_cores \
#         --h5_root $h5_root \
#         --save_root $save_root \
#         --wsi_root $wsi_root

# Tiger2021
# export OPENCV_IO_MAX_IMAGE_PIXELS=10995116277760
# # configuration
# datatype="auto"
# wsi_format="svs"
# level=0
# size=512
# cpu_cores=48
# h5_root="/jhcnas3/Pathology/Patches/BRACS/patches"
# save_root="/jhcnas3/Pathology/Patches/BRACS/images"
# wsi_root="/jhcnas3/BRACS"

# #Array Loop  
# python extract_images.py \
#         --datatype $datatype \
#         --wsi_format $wsi_format \
#         --level $level \
#         --cpu_cores $cpu_cores \
#         --h5_root $h5_root \
#         --save_root $save_root \
#         --wsi_root $wsi_root