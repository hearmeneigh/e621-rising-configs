
## Preview

```bash
export BASE_PATH='/tmp/dr'
export BUILD_PATH='/tmp/dr/build'
export E621_PATH='/tmp/e621-rising-configs'

rm -rf "${BUILD_PATH}"

## artists
python -m database.dr_preview --selector ${E621_PATH}/select/tier-1/helpers/artists.yaml \
  --output "${BUILD_PATH}/preview/tier-1-artists" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 15

python -m database.dr_preview --selector ${E621_PATH}/select/tier-3/helpers/artists.yaml \
  --output "${BUILD_PATH}/preview/tier-3-artists" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 15

python -m database.dr_preview --selector ${E621_PATH}/select/tier-4/helpers/artists.yaml \
  --output "${BUILD_PATH}/preview/tier-4-artists" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 15

## selectors
python -m database.dr_preview --selector ${E621_PATH}/select/tier-1/tier-1.yaml \
  --aggregate \
  --output "${BUILD_PATH}/preview/tier-1" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 1000

python -m database.dr_preview --selector ${E621_PATH}/select/tier-2/tier-2.yaml \
  --aggregate \
  --output "${BUILD_PATH}/preview/tier-2" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 1000

python -m database.dr_preview --selector ${E621_PATH}/select/tier-3/tier-3.yaml \
  --aggregate \
  --output "${BUILD_PATH}/preview/tier-3" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 1000

python -m database.dr_preview --selector ${E621_PATH}/select/tier-4/tier-4.yaml \
  --aggregate \
  --output "${BUILD_PATH}/preview/tier-4" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 1000


## gap analysis
python -m database.dr_gap --selector ${E621_PATH}/select/tier-1/tier-1.yaml \
  --selector ${E621_PATH}/select/tier-2/tier-2.yaml \
  --selector ${E621_PATH}/select/tier-3/tier-3.yaml \
  --selector ${E621_PATH}/select/tier-4/tier-4.yaml \
  --category artist \
  --output "${BUILD_PATH}/preview/gap" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 15
```

## Select
```bash
export BASE_PATH='/tmp/dr'
export BUILD_PATH='/tmp/dr/build'
export E621_PATH='/tmp/e621-rising-configs'

## select samples for the dataset
python -m database.dr_select --selector ${E621_PATH}/select/tier-1/tier-1.yaml \
  --output "${BUILD_PATH}/samples/tier-1.jsonl" \
  --image-format jpg \
  --image-format png

python -m database.dr_select --selector ${E621_PATH}/select/tier-2/tier-2.yaml \
  --output "${BUILD_PATH}/samples/tier-2.jsonl" \
  --image-format jpg \
  --image-format png

python -m database.dr_select --selector ${E621_PATH}/select/tier-3/tier-3.yaml \
  --output "${BUILD_PATH}/samples/tier-3.jsonl" \
  --image-format jpg \
  --image-format png

python -m database.dr_select --selector ${E621_PATH}/select/tier-4/tier-4.yaml \
  --output "${BUILD_PATH}/samples/tier-4.jsonl" \
  --image-format jpg \
  --image-format png
```

## Build
```bash
export BASE_PATH='/tmp/dr'
export BUILD_PATH='/tmp/dr/build'
export DATASET_IMAGE_HEIGHT=1024
export DATASET_IMAGE_WIDTH=1024

# change these:
export AGENT_STRING='<AGENT_STRING>'
export HUGGINGFACE_DATASET_NAME="hearmeneigh/e621-rising-v3-curated"
export S3_DATASET_URL="s3://e621-rising/v3/dataset/curated"

python -m dataset.dr_build --samples "${BUILD_PATH}/samples/tier-1.jsonl:40%" \
  --samples "${BUILD_PATH}/samples/tier-2.jsonl:30%" \
  --samples "${BUILD_PATH}/samples/tier-3.jsonl:20%" \
  --samples "${BUILD_PATH}/samples/tier-4.jsonl:10%" \
  --agent "${AGENT_STRING}" \
  --output "${BUILD_PATH}/dataset/data" \
  --export-tags "${BUILD_PATH}/dataset/tag-counts.json" \
  --export-autocomplete "${BUILD_PATH}/dataset/webui-autocomplete.csv" \
  --min-posts-per-tag 150 \
  --min-tags-per-post 15 \
  --prefilter "${E621_PATH}/dataset/prefilter.yaml" \
  --image-width "${DATASET_IMAGE_WIDTH}" \
  --image-height "${DATASET_IMAGE_HEIGHT}" \
  --image-format jpg \
  --image-quality 95 \
  --num-proc $(nproc) \
  --separator ' ' \
  --limit 10




## build the dataset, download the images, and upload to S3 and Huggingface
## (all images are stored as JPEGs with 85% quality)
python -m dataset.dr_build --samples "${BUILD_PATH}/samples/tier-1.jsonl:40%" \
  --samples "${BUILD_PATH}/samples/tier-2.jsonl:30%" \
  --samples "${BUILD_PATH}/samples/tier-3.jsonl:20%" \
  --samples "${BUILD_PATH}/samples/tier-4.jsonl:10%" \
  --agent "${AGENT_STRING}" \
  --output "${BUILD_PATH}/dataset/data" \
  --export-tags "${BUILD_PATH}/dataset/tag-counts.json" \
  --export-autocomplete "${BUILD_PATH}/dataset/webui-autocomplete.csv" \
  --min-posts-per-tag 150 \
  --min-tags-per-post 15 \
  --prefilter "${E621_PATH}/dataset/prefilter.yaml" \
  --image-width "${DATASET_IMAGE_WIDTH}" \
  --image-height "${DATASET_IMAGE_HEIGHT}" \
  --image-format jpg \
  --image-quality 85 \
  --num-proc $(nproc) \
  --upload-to-hf "${HUGGINGFACE_DATASET_NAME}" \
  --upload-to-s3 "${S3_DATASET_URL}" \
  --separator ' '



```