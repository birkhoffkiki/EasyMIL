export OPENCV_IO_MAX_IMAGE_PIXELS=11258999068426

prefix="/jhcnas3"
# save log
dataset="UBC-OCEAN"
ext=".png"
DATA_DIRECTORY="/jhcnas3/Pathology/original_data/UBC-OCEAN/WSIs/train_images"

#---------------------------------------
root_dir="extract_scripts/"
ramdisk_cache="/mnt/ramdisk/"$dataset

models="conch"
use_cache="no"

gpus["dinov2_vitl"]=6
gpus["phikon"]=5
gpus["conch"]=0


for model in $models
do
        DIR_TO_COORDS=$prefix"/Pathology/Patches/"$dataset
        CSV_FILE_NAME="dataset_csv/"$dataset".csv"
        FEATURES_DIRECTORY=$prefix"/Pathology/Patches/"$dataset
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
                --batch_size 32 \
                --model $model \
                --datatype $datatype \
                --slide_ext $ext \
                --use_cache $use_cache \
                --save_storage $save_storage \
                --ramdisk_cache $cache_root > $root_dir"/logs/"$dataset"_"$model".log" 2>&1 &
done

