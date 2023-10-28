#!/bin/bash -ex

# This script can be used to run the training process for E621 Rising.
# It is configured for one or more Nvidia H100/A100 80GB GPUs

export DATASET="hearmeneigh/e621-rising-v3-finetuner"  # dataset to train on
export OPTIMIZED_DATASET="/workspace/cache/optimize/hearmeneigh/e621-rising-v3-finetuner"  # <-- use this after the first epoch (saves ~24h/epoch)

export BASE_MODEL="stabilityai/stable-diffusion-xl-base-1.0"  # model to start from
export BASE_PATH="/workspace"

export MODEL_NAME="hearmeneigh/e621-rising-v3"  # Huggingface name of the model we're training/finetuning
export RESOLUTION=1024
export EPOCHS_PER_ITERATION=1
export PRECISION=fp16

export OUTPUT_BASE_PATH="${BASE_PATH}/build/model/${MODEL_NAME}-epoch-"
export CACHE_PATH="${BASE_PATH}/cache"

export NCCL_P2P_DISABLE=1
export NCCL_IB_DISABLE=1

# Override Huggingface cache paths
export XDG_CACHE_HOME=
unset XDG_CACHE_HOME
export HF_HOME="${BASE_PATH}/cache/huggingface"
export HF_DATASETS_CACHE="${BASE_PATH}/cache/huggingface/datasets"
export HF_MODULES_CACHE="${BASE_PATH}/cache/huggingface/modules"
export HUGGINGFACE_HUB_CACHE="${BASE_PATH}/cache/huggingface/hub"
export HUGGINGFACE_ASSETS_CACHE="${BASE_PATH}/cache/huggingface/assets"

export MAX_EPOCHS=100

if [ -z "${BATCH_SIZE}" ]
then
  BATCH_SIZE=32
fi

if [ -z "${START_EPOCH}" ]
then
  START_EPOCH=33
fi

if [ -z "${AWS_BASE_PATH}" ]
then
  AWS_BASE_PATH='s3://sd-hmn/v3/e621-rising-v3-epoch-'
fi

if [ -z "${TRAINER_FILE}" ]
then
  export TRAINER_FILE=/usr/local/lib/python3.10/dist-packages/train/dr_train_xl.py
  # export TRAINER_FILE="./venv/lib/python3.11/site-packages/train/dr_train_xl.py"
fi

TRAINER_BASE_PATH=$(dirname "${TRAINER_FILE}")
MODULE_BASE_PATH=$(dirname "${TRAINER_BASE_PATH}")

for ((CUR_ITERATION=0; CUR_ITERATION<$MAX_EPOCHS; CUR_ITERATION++))
do
  CUR_EPOCH=$(($CUR_ITERATION+$START_EPOCH))
  export OUTPUT_PATH="${OUTPUT_BASE_PATH}${CUR_EPOCH}"

  if [ "${CUR_EPOCH}" -eq 1 ]
  then
    export MODEL="${BASE_MODEL}"
    export RESUME_ARG=''
  else
    PREV_EPOCH=$(($CUR_EPOCH-1))
    export MODEL="${OUTPUT_BASE_PATH}${PREV_EPOCH}"
    export DATASET="${OPTIMIZED_DATASET}"
    export RESUME_ARG='--resume-from-checkpoint=latest'
  fi

  cd "${MODULE_BASE_PATH}"

  accelerate launch --mixed_precision=${PRECISION} ${TRAINER_FILE} \
    --pretrained-model-name-or-path=${MODEL} \
    --dataset-name=${DATASET} \
    --resolution=${RESOLUTION} \
    --center-crop \
    --random-flip \
    --train-batch-size=${BATCH_SIZE} \
    --mixed-precision=${PRECISION} \
    --learning-rate=4e-5 \
    --output-dir="${OUTPUT_PATH}" \
    --cache-dir="${CACHE_PATH}" \
    --num-train-epochs=${EPOCHS_PER_ITERATION} \
    --use-8bit-adam \
    --allow-tf32 \
    --snr-gamma=5.0 \
    --max-grad-norm=1 \
    --noise-offset=0.07 \
    --enable-xformers-memory-efficient-attention \
    --lr-scheduler="constant" \
    --lr-warmup-steps=0 \
    --maintain-aspect-ratio \
    --reshuffle-tags \
    --drop-tag-rate=0.7 \
    --gradient-checkpointing \
    --gradient-accumulation-steps=1 \
    --force-temp-dataset-store-dir="${OPTIMIZED_DATASET}" \
    --fingerprint-batch-size=20 \
    --checkpointing-steps=3500 \
    ${RESUME_ARG}

  rm -rf ${OUTPUT_PATH}/checkpoint-*

  dr-convert-sdxl --model-path "${OUTPUT_PATH}" --checkpoint-path "${OUTPUT_PATH}.safetensors" --use-safetensors

  if [ ! -z "${AWS_BASE_PATH}" ]
  then
    aws s3 cp "${OUTPUT_PATH}.safetensors" "${AWS_BASE_PATH}${CUR_EPOCH}.safetensors" &
    aws s3 cp --recursive "${OUTPUT_PATH}" "${AWS_BASE_PATH}${CUR_EPOCH}" &
  fi
done
