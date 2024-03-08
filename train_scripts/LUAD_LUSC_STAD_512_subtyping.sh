# model_names="clam_sb clam_mb mean_mil max_mil att_mil"
# model_names="mean_mil max_mil"
model_names="max_mil mean_mil att_mil clam_sb trans_mil ds_mil"
# model_names='ds_mil'

# backbones="ctranspath plip resnet50"
backbones="resnet50"
k_start=-1
k_end=-1

declare -A in_dim
in_dim["resnet50"]=1024
in_dim["resnet101"]=1024
in_dim["vit_base_patch16_224_21k"]=768
in_dim["ctranspath"]=768
in_dim["vit_large_patch16_224_21k"]=1024
in_dim["plip"]=512
in_dim["dinov2_vitl"]=1024

declare -A gpus
gpus["clam_sb"]=6
gpus["clam_mb"]=6
gpus["mean_mil"]=6
gpus["max_mil"]=7
gpus["att_mil"]=7
gpus["trans_mil"]=7
gpus["ds_mil"]=6


root_log="/storage/Pathology/codes/CLAM/train_scripts/logs/train_log_LUAD_LUSC_STAD_"
task="LUAD_LUSC_STAD"
results_dir="/storage/Pathology/results/experiments/train/"$task
model_size="small" # since the dim of feature of vit-base is 768    
preloading="no"
patch_size="512"


for model in $model_names
do
    for backbone in $backbones
    do
        exp=$model"/"$backbone
        echo $exp", GPU is:"${gpus[$model]}
        export CUDA_VISIBLE_DEVICES=${gpus[$model]}
        # k_start and k_end, only for resuming, default is -1

        nohup python main.py \
            --drop_out \
            --early_stopping \
            --lr 2e-4 \
            --k 1 \
            --k_start $k_start \
            --k_end $k_end \
            --label_frac 1.0 \
            --exp_code $exp \
            --patch_size $patch_size \
            --weighted_sample \
            --bag_loss ce \
            --inst_loss svm \
            --task $task \
            --backbone $backbone \
            --results_dir $results_dir \
            --model_type $model \
            --log_data \
            --data_root_dir DATA_ROOT_DIR \
            --preloading $preloading \
            --model_size $model_size \
            --in_dim ${in_dim[$backbone]} > "$root_log""$model""$backbone.txt" 2>&1 &
    done
done

