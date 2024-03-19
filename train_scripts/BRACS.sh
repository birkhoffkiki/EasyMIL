
# BRACS MIL scripts
# model_names="clam_sb clam_mb mean_mil max_mil att_mil"
model_names="att_mil"
# model_names="moe_a2o"

# backbones="dinov2_vitl||ctranspath"

backbones="dinov2_vitl16_split1"

declare -A in_dim
in_dim["resnet50"]=1024
in_dim["dinov2_vitl16_split1"]=1024
in_dim["ctranspath"]=768
in_dim["phikon"]=768
in_dim["dinov2_vitl"]=1024
in_dim["plip"]=512
in_dim["dinov2_vitl||ctranspath"]="1024||768"
in_dim["phikon||dinov2_vitl||ctranspath"]="768||1024||768"

declare -A gpus
gpus["clam_sb"]=3
gpus["max_mil"]=4
gpus["att_mil"]=7
gpus["wikg"]=7
gpus['moe_a2o']=0
gpus['mamba']=7
gpus['trans_mil']=5
gpus['dtfd']=1

n_classes=7
task="BRACS"
root_log="/storage/Pathology/codes/EasyMIL/train_scripts/logs/train_log_"$task"_"
results_dir="/jhcnas3/Pathology/experiments/train/"$task
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
        k_start=-1
        k_end=-1
        nohup python main.py \
            --drop_out \
            --task_type subtyping \
            --early_stopping \
            --lr 2e-4 \
            --reg 1e-4 \
            --k 10 \
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
            --n_classes $n_classes \
            --in_dim ${in_dim[$backbone]} > "$root_log""$model"_"$backbone.log" 2>&1 &
    done
done

