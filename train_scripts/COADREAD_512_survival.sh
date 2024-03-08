model_names='att_mil'
# model_names='moe_a2o'
# backbones="dinov2_vitl||ctranspath"
backbones="phikon"

declare -A in_dim
in_dim["resnet50"]=1024
in_dim["resnet101"]=1024
in_dim["plip"]=512
in_dim["dinov2_vitl"]=1024
in_dim["ctranspath"]=768
in_dim["phikon"]=768
in_dim["dinov2_vitl||ctranspath"]="1024||768"
declare -A gpus
# gpus["clam_sb"]=0
# gpus["clam_mb"]=1
gpus["mean_mil"]=0
gpus["max_mil"]=0
gpus["att_mil"]=0
gpus["moe"]=4
gpus['moe_a2o']=7
gpus['dtfd']=0
# gpus["trans_mil"]=3

data_root_dir="/storage/Pathology/Patches/TCGA__COADREAD"
root_log="/storage/Pathology/codes/EasyMIL/train_scripts/logs/train_log_COADREAD_survival_"
task="TCGA_COADREAD_survival"
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

