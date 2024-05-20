model_names="att_mil"
backbones="ctranspath phikon distill_87499"
# 

declare -A in_dim

in_dim["distill_379999_cls_only"]=1024
in_dim["distill_87499"]=1024
in_dim["ctranspath"]=768
in_dim["phikon"]=768

declare -A gpus
gpus["clam_sb"]=5
gpus["clam_mb"]=4
gpus["mean_mil"]=5
gpus["max_mil"]=5
gpus["att_mil"]=5
gpus["trans_mil"]=5


task="TUPAC16"
log_dir="eval_scripts/logs"
results="/jhcnas3/Pathology/experiments/train"

save_dir="/jhcnas3/Pathology/experiments/eval"
splits_dir="splits/TUPAC16_100"
n_classes=3
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
            --n_classes $n_classes \
            --task_type subtyping \
            --models_exp_code $model_exp_code \
            --save_exp_code $save_exp_code \
            --task $task \
            --model_type $model \
            --results_dir $results \
            --backbone $backbone \
            --save_dir $save_dir \
            --splits_dir $splits_dir \
            --in_dim ${in_dim[$backbone]}
        
        python cal_mean_std.py --file_path $save_dir"/"$save_exp_code"/summary.csv"
    done
done

