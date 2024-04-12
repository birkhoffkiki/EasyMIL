# tasks="PanCancer-TCGA"
# tasks="PanCancer-TIL"
# tasks="ESCA"
# task="UniToPatho"
# task="BACH"
# tasks="PCAM"
tasks="WSSS4LUAD"
# task="CCRCC-TCGA_HEL"
# task="CRC-100K"
# task="CRC-MSI"

# tasks="PanCancer-TCGA ESCA UniToPatho BACH CCRCC-TCGA_HEL CRC-100K CRC-MSI"

# models="conch uni ctranspath resnet50 plip distill_87499 distill_99999 phikon distill_174999 distill_12499_cls_only"
models="phikon"

export CUDA_VISIBLE_DEVICES=0

for task in $tasks
do
    output_dir="/home/jmabq/data/results"
    data_root="/home/jmabq/data/"$task"/features"


    export PYTHONPATH="${PYTHONPATH}:./"

    for model in $models
    do
        echo "processing: $model"
        nohup python downstream_tasks/linear.py \
            --output_dir $output_dir"/"$task"/linear/"$model \
            --data_dir $data_root"/"$model \
            --batch_size 256 \
            --epochs 3000 > "./downstream_tasks/scripts/"linear-$task"-"$model".log" 2>&1 &
    done
done
