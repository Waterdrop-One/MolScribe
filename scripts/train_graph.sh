#!/bin/bash

NUM_NODES=1
NUM_GPUS_PER_NODE=4
NODE_RANK=0

BATCH_SIZE=128
ACCUM_STEP=1

MASTER_PORT=$(shuf -n 1 -i 10000-65535)

set -x

python -m torch.distributed.launch \
    --nproc_per_node=$NUM_GPUS_PER_NODE --nnodes=$NUM_NODES --node_rank $NODE_RANK --master_addr localhost --master_port $MASTER_PORT \
    train.py \
    --dataset chemdraw \
    --data_path data/molbank \
    --train_file indigo-data/train.csv \
    --valid_file indigo-data/valid.csv \
    --test_file real-acs/test.csv \
    --formats graph \
    --input_size 384 \
    --encoder swin_base_patch4_window12_384 \
    --decoder transformer \
    --encoder_lr 1e-4 \
    --decoder_lr 1e-4 \
    --dynamic_indigo --augment \
    --save_path output/indigo/swin_base_graph_nar2 \
    --epochs 50 \
    --batch_size $((BATCH_SIZE / NUM_GPUS_PER_NODE / ACCUM_STEP)) \
    --gradient_accumulation_steps $ACCUM_STEP \
    --use_checkpoint \
    --warmup 0.05 \
    --print_freq 200 \
    --do_train --do_valid


#    --valid_file indigo-data/valid.csv \
#    --valid_file real-acs-evaluation/test.csv \
#    --save_path output/indigo/swin_base_20_dynamic_aug \
#    --no_pretrained --scheduler cosine --warmup 0.05 \
#    --load_path output/indigo/swin_base_50_dynamic_aug_sgroup1 --resume \