
# camely MIL scripts

model_names="att_mil"

backbones="dinov2_vitl uni conch"
# backbones="dinov2_vitl||ctranspath"


declare -A in_dim
in_dim["resnet50"]=1024
in_dim["phikon"]=768
in_dim["ctranspath"]=768
in_dim["dinov2_vitl"]=1024
in_dim["distill_87499"]=1024
in_dim["plip"]=512


declare -A gpus
gpus["clam_sb"]=7
gpus["clam_mb"]=4
gpus["mean_mil"]=4
gpus["max_mil"]=4
gpus["att_mil"]=2
gpus["moe"]=4


task="camelyon"

results_dir="/jhcnas3/Pathology/experiments/train/712_"$task
model_size="small" # since the dim of feature of vit-base is 768    
preloading="no"
patch_size="512"
n_classes=2


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
            --in_dim ${in_dim[$backbone]} > "train_scripts/logs/camelyon_$model"_"$backbone.txt" 2>&1 &
    done
done

