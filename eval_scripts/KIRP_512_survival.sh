model_names="mean_mil max_mil att_mil ds_mil"
# model_names="max_mil"
# model_names="trans_mil"
# backbones="resnet101"
# backbones="resnet50 resnet101 vit_base_patch16_224_21k vit_large_patch16_224_21k"
# backbones="mae_vit_large_patch16"
backbones="resnet50 resnet101 vit_base_patch16_224_21k vit_large_patch16_224_21k ctranspath dinov2_vitl"

declare -A in_dim
in_dim["resnet50"]=1024
in_dim["resnet101"]=1024
in_dim["vit_base_patch16_224_21k"]=768
in_dim["vit_large_patch16_224_21k"]=1024
in_dim["mae_vit_large_patch16"]=1024
in_dim["dinov2_vitl"]=1024
in_dim["ctranspath"]=768
declare -A gpus
# gpus["clam_sb"]=0
# gpus["clam_mb"]=1
gpus["mean_mil"]=1
gpus["max_mil"]=4
gpus["att_mil"]=5
gpus["ds_mil"]=6

data_root_dir="/storage/Pathology/Patches/TCGA__KIRP"
log_dir="/storage/Pathology/codes/CLAM/eval_scripts/logs/eval_log_KIRP_survival_"
task="TCGA_KIRP_survival"

results="/storage/Pathology/results/experiments/train"

save_dir="/storage/Pathology/results/experiments/eval/"$task
splits_dir="/storage/Pathology/codes/CLAM/splits/"$task"_100"
size=512
for model in $model_names
do
    for backbone in $backbones
    do
        export CUDA_VISIBLE_DEVICES=${gpus[$model]}

        exp=$model"/"$backbone
        echo "processing:"$exp
        model_exp_code=$task"/"$model"/"$backbone"_s1"  # default seed is 1  
        save_exp_code=$task"/"$model"/"$backbone"_s1_512"
        nohup python eval_survival.py \
            --drop_out \
            --k 10 \
            --models_exp_code $model_exp_code \
            --save_exp_code $save_exp_code \
            --task $task \
            --model_type $model \
            --results_dir $results \
            --data_root_dir $data_root_dir \
            --backbone $backbone \
            --save_dir $save_dir \
            --splits_dir $splits_dir \
            --in_dim ${in_dim[$backbone]} > "$log_dir""$model""_""$backbone.txt" 2>&1 &
    done
done

