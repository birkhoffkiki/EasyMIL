# RCC (KICH, KIRC, KIRP)
# save log

prefix="/jhcnas3"
root_dir="extract_scripts/logs/"
ramdisk_cache="/mnt/ramdisk/"
use_cache="no"


models="conch"
# tasks="KIRC"
tasks="KICH KIRP KIRC"

# model="mae_vit_large_patch16"
# model="vit_large_patch16_224_21k"
# model="vit_base_patch16_224_21k"
# model="resnet101"
# model="resnet50"
declare -A gpus
gpus["KICH"]=5
gpus["KIRC"]=5
gpus["KIRP"]=5

declare -A wsi_roots
wsi_roots["KICH"]="/jhcnas3/Pathology/original_data/TCGA/KICH"
wsi_roots["KIRC"]="/jhcnas3/Pathology/original_data/TCGA/KIRC/slides"
wsi_roots["KIRP"]="/jhcnas3/Pathology/original_data/TCGA/KIRP/slides"

for model in $models
do
        for task in $tasks
        do
                DIR_TO_COORDS=$prefix"/Pathology/Patches/TCGA__"$task
                DATA_DIRECTORY=${wsi_roots[$task]}
                CSV_FILE_NAME="dataset_csv/RCC.csv"
                FEATURES_DIRECTORY=$prefix"/Pathology/Patches/TCGA__"$task

                ext=".svs"
                save_storage="yes"
                datatype="tcga" # extra path process for TCGA dataset, direct mode do not care use extra path

                echo $model", GPU is:"${gpus[$task]}
                export CUDA_VISIBLE_DEVICES=${gpus[$task]}

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
                        --ramdisk_cache $ramdisk_cache > $root_dir$task"_log_$model.log" 2>&1 &
        done
done
