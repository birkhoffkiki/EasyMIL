# KIRC
# save log
root_dir="/jhcnas3/Pathology/CLAM/extract_scripts/KIRC_log_"

DIR_TO_COORDS="/jhcnas3/Pathology/Patches/TCGA__KIRC"
DATA_DIRECTORY="/jhcnas2/home/zhoufengtao/data/TCGA/TCGA-KIRC/slides"
CSV_FILE_NAME="/jhcnas3/Pathology/CLAM/dataset_csv/KIRC.csv"
FEATURES_DIRECTORY="/jhcnas3/Pathology/Patches/TCGA__KIRC"
ext=".svs"
save_storage="yes"

ramdisk_cache="/mnt/home/gzr/tmp"
model="mae_vit_large_patch16-1-140000"

# mae_checkpoint='/jhcnas3/Pathology/outputs_vit_l_resume/checkpoint-1-40000.pth'

# model="ctranspath"
# model="mae_vit_large_patch16"

# model="vit_large_patch16_224_21k"
# model="vit_base_patch16_224_21k"
# model="resnet101"
# model="resnet50"


datatype="tcga" # extra path process for TCGA dataset, direct mode do not care use extra path

export CUDA_VISIBLE_DEVICES="2"

nohup python3 extract_features_fp_fast.py \
        --data_h5_dir $DIR_TO_COORDS \
        --data_slide_dir $DATA_DIRECTORY \
        --csv_path $CSV_FILE_NAME \
        --feat_dir $FEATURES_DIRECTORY \
        --batch_size 128 \
        --model $model \
        --datatype $datatype \
        --slide_ext $ext \
        --save_storage $save_storage \
        --ramdisk_cache $ramdisk_cache > "$root_dir""$model.txt" 2>&1 &
