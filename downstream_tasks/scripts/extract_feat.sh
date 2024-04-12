# task="PanCancer-TIL"
# task="PanCancer-TCGA"
# task="PCAM"
# task="UniToPatho"
# task="BACH"
# task="CCRCC-TCGA_HEL"
# tasks="CRC-100K"
tasks="WSSS4LUAD"
# task="CRC-MSI"

# tasks="PanCancer-TCGA ESCA UniToPatho BACH CCRCC-TCGA_HEL CRC-100K CRC-MSI"
# tasks_w_tests="PanCancer-TIL PCAM"

# models="distill_12499_cls_only distill_174999"
# models="distill_12499_cls_only"

export PYTHONPATH="${PYTHONPATH}:/storage/Pathology/codes/EasyMIL"
models="distill_99999 uni resnet50 plip phikon distill_87499 distill_174999 distill_12499_cls_only"
# models="conch"
# models="ctranspath"

declare -A gpus
gpus["phikon"]=0
gpus["distill_12499_cls_only"]=3
gpus["distill_99999"]=5
gpus["distill_87499"]=3
gpus["distill_174999"]=4
gpus["plip"]=7
gpus["resnet50"]=0
gpus["ctranspath"]=0
gpus["conch"]=0
gpus["uni"]=5


for task in $tasks
do
    output_dir="/home/jmabq/data/"$task"/features"
    for model in $models
    do
        echo "processing: $model"
        export CUDA_VISIBLE_DEVICES=${gpus[$model]}
        nohup python downstream_tasks/pre_extract_features.py \
            --output_dir $output_dir \
            --model_name $model \
            --batch_size 128 \
            --train-dataset $task":train" \
            --val-dataset $task":val" > "./downstream_tasks/scripts/"$task"-"$model".log" 2>&1 &
    done
done

for task in $tasks_w_tests
do
    output_dir="/home/jmabq/data/"$task"/features"
    for model in $models
    do
        echo "processing: $model"
        export CUDA_VISIBLE_DEVICES=${gpus[$model]}
        nohup python downstream_tasks/pre_extract_features.py \
            --output_dir $output_dir \
            --model_name $model \
            --batch_size 128 \
            --train-dataset $task":train" \
            --test-dataset $task":test" \
            --val-dataset $task":val" > "./downstream_tasks/scripts/"$task"-"$model".log" 2>&1 &
    done
done
