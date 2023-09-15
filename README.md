# E621 Rising Configuration

This repository has configuration files and scripts for:
* Crawling E621 for posts and tags
* Building a dataset from the crawled data
* Downloading images
* Training a Stable Diffusion 1.x, 2.x, or XL model

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
source ./venv/bin/activate

export BASE_PATH=/workspace
export BUILD_PATH=/workspace/build
export DATASET_IMAGE_HEIGHT=4096
export DATASET_IMAGE_WIDTH=4096

# change these:
export HUGGINGFACE_DATASET_NAME="hearmeneigh/e621-rising-v3-curated"
epxort S3_DATASET_URL="s3://e621-rising/v3/dataset/curated"
export AGENT_STRING='<AGENT_STRING>'


## 1. download tag metadata
dr-crawl --output "${BASE_PATH}/downloads/e621.net/e621-tags.jsonl" --type tags --source e621 --recover --agent "${AGENT_STRING}"


## 2. download post metadata
dr-crawl --output "${BASE_PATH}/downloads/e621.net/e621-posts.jsonl" --type posts --source e621 --recover --agent "${AGENT_STRING}"


## 3. start the database
dr-db-up


## 4. import metadata in the database
dr-import \
  --tags "${BASE_PATH}/downloads/e621.net/e621-tags.jsonl" \
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
dr-preview --selector ./select/positive/artists.yaml --output "${BUILD_PATH}/preview/positive-artists" --output-format html --template ./preview/preview.html.jinja

# selector preview:
dr-preview --selector ./select/positive.yaml --aggregate --output "${BUILD_PATH}/preview/positive" --output-format html --template ./preview/preview.html.jinja
dr-preview --selector ./select/negative.yaml --aggregate --output "${BUILD_PATH}/preview/negative" --output-format html --template ./preview/preview.html.jinja


## 6. select samples for the dataset
dr-select --selector ./select/curated.yaml --output "${BUILD_PATH}/samples/curated.jsonl" --image-format jpg --image-format png
dr-select --selector ./select/positive.yaml --output "${BUILD_PATH}/samples/positive.jsonl" --image-format jpg --image-format png
dr-select --selector ./select/negative.yaml --output "${BUILD_PATH}/samples/negative.jsonl" --image-format jpg --image-format png
dr-select --selector ./select/uncurated.yaml --output "${BUILD_PATH}/samples/uncurated.jsonl" --image-format jpg --image-format png


## 7. stop the database
dr-db-down


## 8. build the dataset, download the images, and upload to S3 and Huggingface
dr-build --samples "${BUILD_PATH}/samples/curated.jsonl:40%" \
  --samples "${BUILD_PATH}/samples/positive.jsonl:30%" \
  --samples "${BUILD_PATH}/samples/negative.jsonl:20%" \
  --samples "${BUILD_PATH}/samples/uncurated.jsonl:10%" \
  --agent "${AGENT_STRING}" \
  --output "${BUILD_PATH}/dataset/data" \
  --export-tags "${BUILD_PATH}/dataset/tag-counts.json" \
  --min-posts-per-tag 150 \
  --min-tags-per-post 10 \
  --prefilter ./dataset/prefilter.yaml \
  --image-width "${DATASET_IMAGE_WIDTH}" \
  --image-height "${DATASET_IMAGE_HEIGHT}" \
  --num-proc $(nproc) \
  --upload-to-huggingface "${HUGGINGFACE_DATASET_NAME}" \
  --upload-to-s3 "${S3_DATASET_URL}" \
  --separator ' ' \
  --image-format jpg \
  --image-quality 85
```


## Training a Model
```bash
cd <e621-rising-configs-root>
source ./venv/bin/activate

export DATASET="hearmeneigh/e621-rising-v3-curated"  # dataset to train on
export BASE_MODEL="stabilityai/stable-diffusion-xl-base-1.0"  # model to start from
export BASE_PATH=/workspace

export MODEL_NAME="hearmeneigh/e621-rising-v3"  # Hugginface name of the model we're building
export MODEL_IMAGE_RESOLUTION=1024
export BATCH_SIZE=32

dr-train --pretrained-model-name-or-path "${BASE_MODEL}" \
  --dataset-name "${DATASET}" \
  --output "${BASE_PATH}/model/${MODEL_NAME}" \
  --resolution "${MODEL_IMAGE_RESOLUTION}" \
  --maintain-aspec-ratio \
  --reshuffle-tags \
  --tag-separator ' ' \
  --random-flip \
  --train-batch-size "${BATCH_SIZE}" \
  --learning-rate 4e-6 \
  --use-ema \
  --max-grad-norm 1 \
  --checkpointing-steps 1000 \
  --lr-scheduler constant \
  --lr-warmup-steps 0
```
