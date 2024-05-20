model_names="att_mil"
backbones="resnet50 ctranspath phikon uni conch plip distill_87499"


declare -A in_dim
in_dim["resnet50"]=1024
in_dim["phikon"]=768
in_dim["plip"]=512
in_dim["dinov2_vitl"]=1024
in_dim["ctranspath"]=768
in_dim["uni"]=1024
in_dim["conch"]=512
in_dim["distill_87499"]=1024


declare -A gpus
gpus["att_mil"]=2
gpus["ds_mil"]=3


data_root_dir="/jhcnas3/Pathology/Patches/TCGA__STAD"
log_dir="eval_scripts/logs/eval_log_STAD_survival_"
task="TCGA_STAD_survival"

results="/storage/Pathology/results/experiments/train"

save_dir="/storage/Pathology/results/experiments/eval/"$task
splits_dir="splits/"$task"_100"

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
            --models_exp_code $model_exp_code \
            --save_exp_code $save_exp_code \
            --task_type survival \
            --n_class 4 \
            --task $task \
            --model_type $model \
            --results_dir $results \
            --data_root_dir $data_root_dir \
            --backbone $backbone \
            --save_dir $save_dir \
            --splits_dir $splits_dir \
            --in_dim ${in_dim[$backbone]} > "$log_dir""$model""_""$backbone.log"
        python cal_mean_std.py --file_path $save_dir"/"$save_exp_code"/summary.csv" --type c-index
    done
done

