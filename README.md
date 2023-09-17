# E621 Rising Dataset Build and Training Configuration

> Build and training configuration for Stable Diffusion XL model [e621-rising-v3](https://huggingface.co/hearmeneigh/e621-rising-v3)

This repository lets you:
* Crawl E621 for posts and tags
* Build a dataset from the crawled data
* Download images
* Train a Stable Diffusion 1.x, 2.x, or XL model
* Publish trained model on Huggingface, S3
* Convert model to Stable Diffusion WebUI compatible version

This configuration uses the [Dataset Rising](https://github.com/hearmeneigh/dataset-rising) toolchain.

## Requirements
* Python `>=3.8`
* Docker `>=24.0.0`

## Setting Up
```bash
cd <e621-rising-configs-root>
python3 -m venv ./venv
pip3 install -r requirements.txt

# Activate Python VENV:
source ./venv/bin/activate
```

## Creating a Dataset
```bash
cd <e621-rising-configs-root>
source ./venv/bin/activate  # you only need to run 'activate' once per session

export BASE_PATH=/workspace
export BUILD_PATH=/workspace/build
export DATASET_IMAGE_HEIGHT=4096
export DATASET_IMAGE_WIDTH=4096

# change these:
export HUGGINGFACE_DATASET_NAME="hearmeneigh/e621-rising-v3-curated"
export S3_DATASET_URL="s3://e621-rising/v3/dataset/curated"
export AGENT_STRING='<AGENT_STRING>'


## 1. download tag metadata
dr-crawl --output "${BASE_PATH}/downloads/e621.net/e621-tags.jsonl" \
  --type tags \
  --source e621 \
  --recover \
  --agent "${AGENT_STRING}"


## 2. download post metadata
dr-crawl --output "${BASE_PATH}/downloads/e621.net/e621-posts.jsonl" \
  --type posts \
  --source e621 \
  --recover \
  --agent "${AGENT_STRING}"


## 3. start the database
dr-db-up


## 4. import metadata in the database
dr-import --tags "${BASE_PATH}/downloads/e621.net/e621-tags.jsonl" \
  --posts "${BASE_PATH}/downloads/e621.net/e621-posts.jsonl" \
  --source e621 \
  --tag-version v2 \
  --prefilter ./tag_normalizer/prefilter.yaml \
  --rewrites ./tag_normalizer/rewrites.yaml \
  --aspect-ratios ./tag_normalizer/aspect_ratios.yaml \
  --category-weights ./tag_normalizer/category_weights.yaml \
  --symbols ./tag_normalizer/symbols.yaml \
  --remove-old


## 5. (optional) preview dataset selectors

# category selector preview (artists):
dr-preview --selector ./select/positive/artists.yaml \
  --output "${BUILD_PATH}/preview/positive-artists" \
  --output-format html \
  --template ./preview/preview.html.jinja
  
# selector preview:
dr-preview --selector ./select/positive.yaml \
  --aggregate \
  --output "${BUILD_PATH}/preview/positive" \
  --output-format html \
  --template ./preview/preview.html.jinja

dr-preview --selector ./select/negative.yaml \
  --aggregate \
  --output "${BUILD_PATH}/preview/negative" \
  --output-format html \
  --template ./preview/preview.html.jinja


## 6. select samples for the dataset
dr-select --selector ./select/curated.yaml \
  --output "${BUILD_PATH}/samples/curated.jsonl" \
  --image-format jpg \
  --image-format png

dr-select --selector ./select/positive.yaml \
  --output "${BUILD_PATH}/samples/positive.jsonl" \
  --image-format jpg \
  --image-format png

dr-select --selector ./select/negative.yaml \
  --output "${BUILD_PATH}/samples/negative.jsonl" \
  --image-format jpg \
  --image-format png

dr-select --selector ./select/uncurated.yaml \
  --output "${BUILD_PATH}/samples/uncurated.jsonl" \
  --image-format jpg \
  --image-format png


## 7. stop the database
dr-db-down


## 8. build the dataset, download the images, and upload to S3 and Huggingface
##    (all images are stored as JPEGs with 85% quality)
dr-build --samples "${BUILD_PATH}/samples/curated.jsonl:40%" \
  --samples "${BUILD_PATH}/samples/positive.jsonl:30%" \
  --samples "${BUILD_PATH}/samples/negative.jsonl:20%" \
  --samples "${BUILD_PATH}/samples/uncurated.jsonl:10%" \
  --agent "${AGENT_STRING}" \
  --output "${BUILD_PATH}/dataset/data" \
  --export-tags "${BUILD_PATH}/dataset/tag-counts.json" \
  --export-autocomplete "${BUILD_PATH}/dataset/webui-autocomplete.csv" \
  --min-posts-per-tag 150 \
  --min-tags-per-post 15 \
  --prefilter ./dataset/prefilter.yaml \
  --image-width "${DATASET_IMAGE_WIDTH}" \
  --image-height "${DATASET_IMAGE_HEIGHT}" \
  --image-format jpg \
  --image-quality 85 \
  --num-proc $(nproc) \
  --upload-to-hf "${HUGGINGFACE_DATASET_NAME}" \
  --upload-to-s3 "${S3_DATASET_URL}" \
  --separator ' '
```


## Training a Model
When training a Stable Diffusion XL model, can train **two** models: [`stabilityai/stable-diffusion-xl-base-1.0`](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0) and [`stabilityai/stable-diffusion-xl-refiner-1.0`](https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0).
(If unsure what to do, start with the base model.)


```bash
cd <e621-rising-configs-root>
source ./venv/bin/activate  # you only need to run 'activate' once per session

export DATASET="hearmeneigh/e621-rising-v3-curated"  # dataset to train on
export BASE_MODEL="stabilityai/stable-diffusion-xl-base-1.0"  # model to start from
export BASE_PATH=/workspace

export MODEL_NAME="hearmeneigh/e621-rising-v3"  # Huggingface name of the model we're building
export MODEL_IMAGE_RESOLUTION=1024
export EPOCHS=10
export BATCH_SIZE=1  # in real training, batch size should be as high as possible;
                     # it will require a lot of GPU memory
export PRECISION=no  # no, bf16, or fp16 depending on your GPU; use 'no' if unsure


# 1. train model
dr-train --pretrained-model-name-or-path "${BASE_MODEL}" \
  --dataset-name "${DATASET}" \
  --output-dir "${BASE_PATH}/model/${MODEL_NAME}" \
  --cache-path "${BASE_PATH}/cache/model/${MODEL_NAME}" \
  --resolution "${MODEL_IMAGE_RESOLUTION}" \
  --maintain-aspec-ratio \
  --reshuffle-tags \
  --tag-separator ' ' \
  --center-crop \
  --random-flip \
  --train-batch-size "${BATCH_SIZE}" \
  --learning-rate 4e-6 \
  --use-ema \
  --max-grad-norm 1.0 \
  --checkpointing-steps 5000 \
  --lr-scheduler constant \
  --lr-warmup-steps 0 \
  --mixed-precision "${PRECISION}" \
  --resume-from-checkpoint "latest" \
  --dataloader-num-workers $(nproc)
  # optional:
  # --enable-xformers-memory-efficient-attention


# 2. upload model to Huggingface
dr-upload-hf --model-path "${BASE_PATH}/model/${MODEL_NAME}" --hf-model-name "${MODEL_NAME}"


# 3. convert model to safetensors -- this version can be used with Stable Diffusion WebUI
dr-convert-sdxl \
  --model_path "${BASE_PATH}/model/${MODEL_NAME}" \
  --checkpoint_path "${BASE_PATH}/model/${MODEL_NAME}.safetensors" \
  --use_safetensors
```
