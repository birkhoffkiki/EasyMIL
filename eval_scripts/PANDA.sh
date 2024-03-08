# model_names="clam_mb clam_sb mean_mil max_mil att_mil trans_mil"

# camely MIL scripts
model_names="att_mil"
# model_names="simple"
# model_names="att_mil"

# backbones="resnet50"
backbones="plip"
# backbones="mae_vit_large_patch16-1epoch-180M"
# backbones="ctranspath plip"
# backbones="dinov2_vitl"

declare -A in_dim
in_dim["resnet50"]=1024
in_dim["ctranspath"]=768
in_dim["dinov2_vitl"]=1024
in_dim["plip"]=512


declare -A gpus
gpus["clam_sb"]=3
gpus["mean_mil"]=6
gpus["max_mil"]=6
gpus["att_mil"]=6
gpus["trans_mil"]=6
gpus["dtfd"]=3
gpus['simple']=6


log_dir="/storage/Pathology/codes/EasyMIL/eval_scripts/logs"
task="PANDA"
results="/jhcnas3/Pathology/experiments/train"
save_dir="/jhcnas3/Pathology/experiments/eval"

splits_dir="/storage/Pathology/codes/EasyMIL/splits/"$task"_100"
size=512
n_classes=6

for model in $model_names
do
    for backbone in $backbones
    do
        export CUDA_VISIBLE_DEVICES=${gpus[$model]}

        exp=$model"/"$backbone
        echo "processing:"$exp
        model_exp_code=$task"/"$model"/"$backbone"_s1"  # default seed is 1  
        save_exp_code=$task"/"$model"/"$backbone"_s1_512"
        python eval.py \
            --drop_out \
            --k 10 \
            --task_type subtyping \
            --models_exp_code $model_exp_code \
            --save_exp_code $save_exp_code \
            --n_classes $n_classes \
            --task $task \
            --model_type $model \
            --results_dir $results \
            --backbone $backbone \
            --save_dir $save_dir \
            --splits_dir $splits_dir \
            --in_dim ${in_dim[$backbone]} > $log_dir"/"$task"_"$model"_"$backbone".txt"

        python cal_mean_std.py --file_path $save_dir"/"$save_exp_code"/summary.csv"
    done
done

