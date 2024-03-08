# RCC MIL scripts

model_names="att_mil"

# backbones="dinov2_vitl||ctranspath"
backbones="phikon"


declare -A in_dim
in_dim["resnet50"]=1024
in_dim["resnet101"]=1024
in_dim["ctranspath"]=768
in_dim["phikon"]=768
in_dim["dinov2_vitl"]=1024
in_dim["dinov2_vitl||ctranspath"]="1024||768"
in_dim["plip"]=512


declare -A gpus
gpus["clam_sb"]=7
gpus["clam_mb"]=4
gpus["mean_mil"]=4
gpus["max_mil"]=4
gpus["att_mil"]=6
gpus["moe"]=2

n_classes=3
task="RCC"
root_log="/storage/Pathology/codes/EasyMIL/train_scripts/logs/train_log_"$task"_"
results_dir="/jhcnas3/Pathology/experiments/train/"$task
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
        # CUDA_VISIBLE_DEVICES=2,3,0,4,5,6,7 nohup torchrun --nproc_per_node=7 --master_port=29501 main.py \
        nohup python main.py \
            --drop_out \
            --early_stopping \
            --lr 2e-4 \
            --k 10 \
            --k_start $k_start \
            --k_end $k_end \
            --label_frac 1.0 \
            --exp_code $exp \
            --patch_size $patch_size \
            --weighted_sample \
            --task $task \
            --backbone $backbone \
            --results_dir $results_dir \
            --model_type $model \
            --log_data \
            --preloading $preloading \
            --n_classes $n_classes \
            --in_dim ${in_dim[$backbone]} > "$root_log""$model"_"$backbone.txt" 2>&1 &
    done
done

