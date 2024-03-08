# Camelyon
# save log
root_dir="/storage/Pathology/codes/EasyMIL/extract_scripts/"
ramdisk_cache="/mnt/ramdisk/PANDA"
use_cache="no"
# models="ctranspath plip"
models="phikon"

declare -A gpus
gpus["phikon"]=6
gpus["plip"]=2
gpus["ctranspath"]=2
gpus["resnet50"]=7
gpus["dinov2_vitl"]=5


for model in $models
do
        DIR_TO_COORDS="/storage/Pathology/Patches/PANDA"
        DATA_DIRECTORY="/jhcnas3/Pathology/original_data/PANDA/train_images"
        CSV_FILE_NAME="/storage/Pathology/codes/EasyMIL/dataset_csv/PANDA.csv"
        FEATURES_DIRECTORY="/storage/Pathology/Patches/PANDA"
        ext=".tiff"
        save_storage="yes"
        datatype="direct" # extra path process for TCGA dataset, direct mode do not care use extra path

        echo $model", GPU is:"${gpus[$model]}
        export CUDA_VISIBLE_DEVICES=${gpus[$model]}
        cache_root=$ramdisk_cache"/"$model
        nohup python3 extract_features_fp_fast.py \
                --data_h5_dir $DIR_TO_COORDS \
                --data_slide_dir $DATA_DIRECTORY \
                --csv_path $CSV_FILE_NAME \
                --feat_dir $FEATURES_DIRECTORY \
                --batch_size 32 \
                --model $model \
                --datatype $datatype \
                --slide_ext $ext \
                --use_cache $use_cache \
                --save_storage $save_storage \
                --ramdisk_cache $cache_root > $root_dir"/logs/PANDA_log_$model.txt" 2>&1 &
done
