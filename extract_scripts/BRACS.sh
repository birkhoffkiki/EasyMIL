# save log
root_dir="/storage/Pathology/codes/EasyMIL/extract_scripts/"
ramdisk_cache="/mnt/ramdisk/BRACS"
use_cache="no"

models="phikon"

declare -A gpus
gpus["dinov2_vitl"]=6
gpus["phikon"]=7
gpus["plip"]=6
gpus["ctranspath"]=5
gpus["resnet50"]=6


for model in $models
do
        DIR_TO_COORDS="/storage/Pathology/Patches/BRACS"
        DATA_DIRECTORY=/jhcnas3/BRACS/BRACS_WSI
        CSV_FILE_NAME="/storage/Pathology/codes/EasyMIL/dataset_csv/BRACS.csv"
        FEATURES_DIRECTORY="/storage/Pathology/Patches/BRACS"
        ext=".svs"
        save_storage="yes"
        datatype="auto" # extra path process for TCGA dataset, direct mode do not care use extra path

        echo $model", GPU is:"${gpus[$model]}
        export CUDA_VISIBLE_DEVICES=${gpus[$model]}
        cache_root=$ramdisk_cache"/"$model
        nohup python3 extract_features_fp_fast.py \
                --data_h5_dir $DIR_TO_COORDS \
                --data_slide_dir $DATA_DIRECTORY \
                --csv_path $CSV_FILE_NAME \
                --feat_dir $FEATURES_DIRECTORY \
                --batch_size 64 \
                --model $model \
                --datatype $datatype \
                --slide_ext $ext \
                --use_cache $use_cache \
                --save_storage $save_storage \
                --ramdisk_cache $cache_root > $root_dir"/logs/BRACS_log_$model.txt" 2>&1 &
done
