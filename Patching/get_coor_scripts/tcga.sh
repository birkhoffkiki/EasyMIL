export OPENCV_IO_MAX_IMAGE_PIXELS=10995116277760
# ----TCGA---------
types="ACC
BLCA
BRCA
CESC
CHOL
COAD
DLBC
ESCA
GBM
HNSC
KICH
KIRC
KIRP
LGG
LIHC
LUAD
LUSC
MESO
OV
PAAD
PCPG
PRAD
READ
SARC
SKCM
STAD
TGCT
THCA
THYM
UCEC
UCS
UVM"


save_dir="/storage/Pathology/Patches/TCGA__"
source_dir="/jhcnas2/home/zhoufengtao/data/TCGA/TCGA-"
wsi_format="svs"
size=512
#Array Loop  
for subtype in $types
do
    echo Processing $subtype
    python create_patches_fp.py \
            --source $source_dir$subtype"/slides" \
            --save_dir $save_dir$subtype \
            --preset tcga.csv \
            --patch_level 0 \
            --patch_size $size \
            --step_size $size \
            --wsi_format $wsi_format \
            --seg \
            --patch \
            --stitch 
done
