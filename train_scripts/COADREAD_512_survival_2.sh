# model_names="clam_sb clam_mb mean_mil max_mil att_mil trans_mil"
# model_names="max_mil"
model_names="mean_mil max_mil att_mil ds_mil"
# model_names='ds_mil'
# deep_attn_misl_mode='cluster'
mode='path'
backbones="mae_vit_large_patch16"
# backbones="vit_large_patch16_224_21k"
# backbones="resnet50 resnet101 vit_base_patch16_224_21k vit_large_patch16_224_21k"
# backbones="resnet50 resnet101 vit_base_patch16_224_21k"
declare -A in_dim
in_dim["resnet50"]=1024
in_dim["resnet101"]=1024
in_dim["vit_base_patch16_224_21k"]=768
in_dim["vit_large_patch16_224_21k"]=1024
in_dim["mae_vit_large_patch16"]=1024
declare -A gpus
# gpus["clam_sb"]=0
# gpus["clam_mb"]=1
gpus["mean_mil"]=0
gpus["max_mil"]=0
gpus["att_mil"]=0
# gpus["trans_mil"]=3
gpus["ds_mil"]=2

data_root_dir="/jhcnas3/Pathology/Patches/TCGA__COADREAD"
root_log="/jhcnas3/Pathology/CLAM/train_scripts/train_log_COADREAD_survival_"
task="TCGA_COADREAD_survival"
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
        nohup python main_survival.py \
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
            --bag_loss nll_surv \
            --task $task \
            --backbone $backbone \
            --results_dir $results_dir \
            --model_type $model \
            --mode $mode \
            --log_data \
            --data_root_dir $data_root_dir \
            --preloading $preloading \
            --model_size $model_size \
            --in_dim ${in_dim[$backbone]} > "$root_log""$model""$backbone.txt" 2>&1 &
    done
done

