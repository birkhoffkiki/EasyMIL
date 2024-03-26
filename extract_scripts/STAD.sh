# LUAD 
prefix="/jhcnas3"
task="STAD"
root_dir="extract_scripts/logs/STAD_log_"
# ramdisk_cache="/home/gzr/tmp/tmp_stad"

ramdisk_cache='/mnt/ramdisk/stad'
DIR_TO_COORDS=$prefix"/Pathology/Patches/TCGA__STAD"
DATA_DIRECTORY="/jhcnas3/Pathology/original_data/TCGA/STAD/slides"
CSV_FILE_NAME="dataset_csv/STAD.csv"
FEATURES_DIRECTORY=$prefix"/Pathology/Patches/TCGA__STAD"
ext=".svs"
save_storage="yes"
use_cache='no'

models="conch"
# models="ctranspath"
declare -A gpus
gpus["phikon"]=1
gpus["ctranspath"]=3
gpus["plip"]=1
gpus["conch"]=0
gpus["dinov2_vitl"]=2


datatype="tcga" # extra path process for TCGA dataset, direct mode do not care use extra path

for model in $models
do
        echo $model", GPU is:"${gpus[$model]}
        export CUDA_VISIBLE_DEVICES=${gpus[$model]}

        nohup python3 extract_features_fp_fast.py \
                --data_h5_dir $DIR_TO_COORDS \
                --data_slide_dir $DATA_DIRECTORY \
                --csv_path $CSV_FILE_NAME \
                --feat_dir $FEATURES_DIRECTORY \
                --batch_size 32 \
                --model $model \
                --use_cache $use_cache \
                --datatype $datatype \
                --slide_ext $ext \
                --save_storage $save_storage \
                --ramdisk_cache $ramdisk_cache > $root_dir$task"_log_$model.txt" 2>&1 &


done