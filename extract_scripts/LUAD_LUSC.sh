# LUAD LUSC
# save log
root_dir="/storage/Pathology/codes/EasyMIL/extract_scripts/logs/"
ramdisk_cache="/mnt/ramdisk/LUAD_LUSC"
use_cache="no"
mkdir $ramdisk_cache;

# models="phikon"
models="dinov2_vitl16_split1 dinov2_vitl14_split1"

tasks="LUAD LUSC"
declare -A gpus
gpus["dinov2_vitl"]=0
gpus["dinov2_vitl16_split1"]=5
gpus["dinov2_vitl14_split1"]=5
gpus["phikon"]=6
gpus["plip"]=2

for model in $models
do
        for task in $tasks
        do
                DIR_TO_COORDS="/storage/Pathology/Patches/TCGA__"$task
                DATA_DIRECTORY="/jhcnas3/Pathology/original_data/TCGA/"$task"/slides"
                CSV_FILE_NAME="/storage/Pathology/codes/EasyMIL/dataset_csv/LUAD_LUSC.csv"
                FEATURES_DIRECTORY="/storage/Pathology/Patches/TCGA__"$task
                ext=".svs"
                save_storage="yes"
                datatype="tcga" # extra path process for TCGA dataset, direct mode do not care use extra path

                echo $model", GPU is:"${gpus[$model]}
                export CUDA_VISIBLE_DEVICES=${gpus[$model]}

                nohup python3 extract_features_fp_fast.py \
                        --data_h5_dir $DIR_TO_COORDS \
                        --data_slide_dir $DATA_DIRECTORY \
                        --csv_path $CSV_FILE_NAME \
                        --feat_dir $FEATURES_DIRECTORY \
                        --batch_size 32 \
                        --use_cache $use_cache \
                        --model $model \
                        --datatype $datatype \
                        --slide_ext $ext \
                        --save_storage $save_storage \
                        --ramdisk_cache $ramdisk_cache > $root_dir$task"_log_$model.txt" 2>&1 &
        done
done
