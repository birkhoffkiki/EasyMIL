# tasks="PanCancer-TIL"
# tasks="PanCancer-TCGA"
# tasks="PCAM"
# tasks="UniToPatho"
# tasks="BACH"
# tasks="CCRCC-TCGA_HEL"
tasks="CRC-100K"
# tasks="LYSTO"
# tasks="ESCA"
# tasks="WSSS4LUAD"
# tasks="CRC-MSI"
# tasks="CRC-MSI"
# tasks="BreakHis"
# tasks="chaoyang"

# tasks="PanCancer-TCGA ESCA UniToPatho BACH CCRCC-TCGA_HEL CRC-100K CRC-MSI WSSS4LUAD PanCancer-TIL PCAM BreakHis chaoyang"
# tasks="UniToPatho PanCancer-TIL"


export PYTHONPATH="${PYTHONPATH}:/storage/Pathology/codes/EasyMIL"
# models="distill_87499 resnet50 uni"
# models="plip phikon conch"
models="ctranspath"


declare -A gpus
gpus["chaoyang"]=4
gpus["LYSTO"]=6
gpus["PanCancer-TCGA"]=1
gpus["PanCancer-TIL"]=4
gpus["ESCA"]=3
gpus["UniToPatho"]=3
gpus["BACH"]=6
gpus["BreakHis"]=4
gpus["CCRCC-TCGA_HEL"]=6
gpus["CRC-100K"]=1
gpus["CRC-MSI"]=1
gpus["WSSS4LUAD"]=4
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