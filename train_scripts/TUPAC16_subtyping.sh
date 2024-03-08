
# model_names="max_mil mean_mil att_mil trans_mil ds_mil dtfd"
model_names="att_mil"
backbones="resnet50 ctranspath plip"


declare -A in_dim
in_dim["resnet50"]=1024
in_dim["resnet101"]=1024
in_dim["ctranspath"]=768
in_dim["dinov2_vitl"]=1024
in_dim["dinov2_vitl||ctranspath"]="1024||768"
in_dim["plip"]=512


declare -A gpus
gpus["clam_sb"]=7
gpus["clam_mb"]=4
gpus["mean_mil"]=6
gpus["max_mil"]=6
gpus["att_mil"]=6
gpus['trans_mil']=7
gpus['ds_mil']=6
gpus['dtfd']=6
gpus['hat_encoder_256_32']=4 #√
gpus['hat_encoder_512_512']=7 #√
gpus['hat_encoder_256_256']=4 #√
gpus['96_hat_encoder_512_512']=4 #√
gpus['512_hat_encoder_512_512']=6 #√
gpus['128_hat_encoder_512_512']=4 #√
gpus['64_hat_encoder_512_512']=5 #√
gpus['256_hat_encoder_512_512']=5 #√ 
gpus['96_hat_encoder_512_512_nomem']=7 #√
gpus['hat_encoder_256_32_nomem']=6 #√ 
gpus["moe"]=3



root_log="/storage/Pathology/codes/EasyMIL/train_scripts/logs/train_log_TUPAC16_"
task="TUPAC16"
results_dir="/jhcnas3/Pathology/experiments/train/"$task
# results_dir="/storage/Pathology/results/experiments/train/"$task
model_size="small" # since the dim of feature of vit-base is 768    
preloading="no"
patch_size="512"
n_classes=3


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
            --n_classes $n_classes \
            --task_type subtyping \
            --lr 1e-4 \
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
            --model_size $model_size \
            --in_dim ${in_dim[$backbone]} > "$root_log""$model""_""$backbone.txt" 2>&1 &
    done
done

