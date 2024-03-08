
# model_names="moe"
# backbones="dinov2_vitl||ctranspath"
model_names="att_mil"
backbones="phikon"

declare -A in_dim
in_dim["resnet50"]=1024
in_dim["phikon"]=768
in_dim["dinov2_vitl||ctranspath"]="1024||768"
in_dim["plip"]=512
in_dim["dinov2_vitl"]=1024
in_dim["ctranspath"]=768

declare -A gpus
gpus["plip"]=0
gpus["max_mil"]=0
gpus["att_mil"]=7
gpus["moe"]=1
gpus['llama']=0
gpus['dtfd']=0

data_root_dir="/storage/Pathology/Patches/TCGA__LUAD"
root_log="/storage/Pathology/codes/EasyMIL/train_scripts/logs/train_log_LUAD_survival_"
task="TCGA_LUAD_survival"
results_dir="/jhcnas3/Pathology/experiments/train/"$task
# results_dir="/storage/Pathology/results/experiments/train/"$task
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
            --early_stopping \
            --task_type survival \
            --lr 2e-4 \
            --k 10 \
            --k_start $k_start \
            --k_end $k_end \
            --label_frac 1.0 \
            --exp_code $exp \
            --patch_size $patch_size \
            --weighted_sample \
            --bag_loss nll_surv \
            --task $task \
            --backbone $backbone \
            --results_dir $results_dir \
            --model_type $model \
            --log_data \
            --data_root_dir $data_root_dir \
            --preloading $preloading \
            --model_size $model_size \
            --in_dim ${in_dim[$backbone]} > "$root_log""$model""$backbone.log" 2>&1 &
    done
done

