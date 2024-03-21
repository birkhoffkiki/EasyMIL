# save log
dataset="TUPAC16"
ext=".svs"
DATA_DIRECTORY="/jhcnas3/Pathology/original_data/TUPAC16/slides"
data_prefix="/jhcnas3/Pathology/"

#---------------------------------------
root_dir="extract_scripts/"
ramdisk_cache="/mnt/ramdisk/"$dataset
models="conch"
# models="plip"

declare -A gpus
gpus["dinov2_vitl"]=6
gpus["phikon"]=1
gpus["uni"]=1
gpus["conch"]=1
gpus["plip"]=4
gpus["dinov2_vitl16_split1"]=2
gpus["ctranspath"]=0
gpus["resnet50"]=7
use_cache="no"

for model in $models
do
        DIR_TO_COORDS=$data_prefix"Patches/"$dataset
        CSV_FILE_NAME="dataset_csv/TUPAC16.csv"
        FEATURES_DIRECTORY=$data_prefix"Patches/"$dataset
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
                --batch_size 16 \
                --model $model \
                --use_cache $use_cache \
                --datatype $datatype \
                --slide_ext $ext \
                --save_storage $save_storage \
                --ramdisk_cache $cache_root > $root_dir"/logs/"$dataset"_"$model".log" 2>&1 &
done
