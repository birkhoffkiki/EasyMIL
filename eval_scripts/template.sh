root="/jhcnas3/Pathology/experiments/train/TCGA_BRCA_subtyping/DTFD"
targets="ctranspath dinov2_vitl resnet50 plip"

for model in $targets
do
    p=$root"/"$model"_s1/summary.csv"
    echo $p
    python cal_mean_std.py --file_path $p
done
