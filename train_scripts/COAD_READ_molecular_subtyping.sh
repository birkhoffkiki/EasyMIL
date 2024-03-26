# COAD_READ molecular subtyping MIL scripts
#model_names="wikg"
model_names="att_mil"
# model_names="moe"

backbones="resnet50 ctranspath phikon dinov2_vitl plip"

#  plip dinov2_vitl"
# backbones="dinov2_vitl||ctranspath"


declare -A in_dim
in_dim["resnet50"]=1024
in_dim["ctranspath"]=768
in_dim["phikon"]=768
in_dim["dinov2_vitl"]=1024
in_dim["plip"]=512
in_dim["dinov2_vitl||ctranspath"]="1024||768"
in_dim["uni"]=1024
in_dim["conch"]=512

declare -A gpus
gpus["clam_sb"]=5
gpus["wikg"]=6
gpus["max_mil"]=5
gpus["att_mil"]=0
gpus['simple']=5
gpus['DTFD']=5
gpus["moe_a2o"]=5
gpus["ds_mil"]=5
gpus["moe"]=5
gpus["trans_mil"]=5


n_classes=4
task="TCGA_COAD_READ_molecular_subtyping"
root_log="/storage/Pathology/codes/EasyMIL/train_scripts/logs/train_log_"$task"_"
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
        nohup python main.py \
            --drop_out \
            --task_type subtyping \
            --early_stopping \
            --lr 1e-4 \
            --reg 1e-4 \
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
            --in_dim ${in_dim[$backbone]} > "$root_log""$model"_"$backbone.txt" 2>&1 &
    done
done

