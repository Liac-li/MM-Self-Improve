#!/bin/bash
# export PYTHONPATH=$PYTHONPATH:$PWD
# source scripts/eval/config.sh
export CUDA_VISIBLE_DEVICES=${9:-0,1,2,3,4,5,6,7}

if [ -z "$1" ]; then
  echo "Error: Missing result file path."
  exit 1
fi

if [ -z "$2" ]; then
  echo "Error: Missing sample1 file path."
  exit 1
fi

if [ -z "$3" ]; then
  echo "Error: Missing sample2 file path."
  exit 1
fi

if [ -z "$4" ]; then
  echo "Error: Missing sample3 file path."
  exit 1
fi

if [ -z "$5" ]; then
  echo "Error: Missing model file path."
  exit 1
fi

if [ -z "$6" ]; then
  echo "Error: Missing do_sample parameter (true/false)."
  exit 1
fi

if [ -z "$7" ]; then
  echo "Error: Missing data root path."
  exit 1
fi

result=$1
sample1=$2
sample2=$3
sample3=$4
model=$5
do_sample=$6
data_root=$7
num_processes=${8:-8}

if [ "$do_sample" = "true" ]; then
    do_sample_flag="--do_sample"
else
    do_sample_flag=""
fi

tab_test="$data_root/problems_test.json"
batch_size=${BATCH_SIZE:-4}

accelerate launch --config_file accelerate_config/infer.yaml --num_processes $num_processes --main_process_port 29503 \
    -m vlrlhf.eval.tabmwp.eval_v \
    --data_root $data_root \
    --tab_test_file $tab_test \
    --tab_test_sample1 $sample1 \
    --tab_test_sample2 $sample2 \
    --tab_test_sample3 $sample3 \
    --model_path $model \
    --output_path $result \
    --batch_size $batch_size \
    $do_sample_flag

python -m vlrlhf.eval.tabmwp.calculate \
        --result_file $result \
        --tab_test_file $tab_test