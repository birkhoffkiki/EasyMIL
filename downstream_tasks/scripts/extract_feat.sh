# tasks="PanCancer-TIL"
# tasks="PanCancer-TCGA"
# tasks="PCAM"
# tasks="UniToPatho"
# tasks="BACH"
# tasks="CCRCC-TCGA_HEL"
# tasks="CRC-100K"
# tasks="ESCA"
# tasks="WSSS4LUAD"
# tasks="CRC-MSI"
# tasks="CRC-MSI"
tasks="BreakHis"

# tasks="PanCancer-TCGA ESCA UniToPatho BACH CCRCC-TCGA_HEL CRC-100K CRC-MSI WSSS4LUAD PanCancer-TIL PCAM"
# tasks_w_tests="PanCancer-TIL PCAM"

# models="distill_12499_cls_only distill_174999"
# models="distill_12499"

export PYTHONPATH="${PYTHONPATH}:/storage/Pathology/codes/EasyMIL"
# models="distill_99999 uni resnet50 plip phikon distill_87499 distill_174999 distill_12499_cls_only"
models="conch"
# models="distill_12499"
# models="dinov2_vitl"

declare -A gpus
gpus["PanCancer-TCGA"]=2
gpus["PanCancer-TIL"]=6
gpus["ESCA"]=4
gpus["UniToPatho"]=5
gpus["BACH"]=6
gpus["BreakHis"]=6
gpus["CCRCC-TCGA_HEL"]=7
gpus["CRC-100K"]=5
gpus["CRC-MSI"]=2
gpus["WSSS4LUAD"]=7
gpus["PCAM"]=6


for task in $tasks
do
    output_dir="/home/jmabq/data/"$task"/features"
    for model in $models
    do
        echo "processing: $model, $task"
        export CUDA_VISIBLE_DEVICES=${gpus[$task]}
        nohup python downstream_tasks/pre_extract_features.py \
            --output_dir $output_dir \
            --model_name $model \
            --batch_size 32 \
            --train-dataset $task":train" \
            --val-dataset $task":val" > "./downstream_tasks/scripts/"$task"-"$model".log" 2>&1 &
    done
done