
# camely MIL scripts

model_names="att_mil"

backbones="resnet50 plip ctranspath uni phikon distill_87499"


declare -A in_dim
in_dim["resnet50"]=1024
in_dim["uni"]=1024
in_dim["phikon"]=768
in_dim["ctranspath"]=768
in_dim["distill_87499"]=1024
in_dim["plip"]=512
in_dim["conch"]=512


declare -A gpus
gpus["att_mil"]=1


task="eBrains_oncotree"

results_dir="/jhcnas3/Pathology/experiments/train/"$task
model_size="small" # since the dim of feature of vit-base is 768    
preloading="yes"
patch_size="512"
n_classes=32


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
            --k 5 \
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
            --in_dim ${in_dim[$backbone]} > "train_scripts/logs/eBrains_oncotree_$model"_"$backbone.txt" 2>&1 &
    done
done

