
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

python -m database.dr_preview --selector ${E621_PATH}/select/extras/extras.yaml \
  --aggregate \
  --output "${BUILD_PATH}/preview/extras" \
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

python -m database.dr_select --selector ${E621_PATH}/select/extras/extras.yaml \
  --output "${BUILD_PATH}/samples/extras.jsonl" \
  --image-format jpg \
  --image-format png

###### OR #####

dr-select --selector ${E621_PATH}/select/tier-1/tier-1.yaml \
  --output "${BUILD_PATH}/samples/tier-1.jsonl" \
  --image-format jpg \
  --image-format png

dr-select --selector ${E621_PATH}/select/tier-2/tier-2.yaml \
  --output "${BUILD_PATH}/samples/tier-2.jsonl" \
  --image-format jpg \
  --image-format png

dr-select --selector ${E621_PATH}/select/tier-3/tier-3.yaml \
  --output "${BUILD_PATH}/samples/tier-3.jsonl" \
  --image-format jpg \
  --image-format png

dr-select --selector ${E621_PATH}/select/tier-4/tier-4.yaml \
  --output "${BUILD_PATH}/samples/tier-4.jsonl" \
  --image-format jpg \
  --image-format png

dr-select --selector ${E621_PATH}/select/extras/extras.yaml \
  --output "${BUILD_PATH}/samples/extras.jsonl" \
  --image-format jpg \
  --image-format png
```

## Join
```bash
export BASE_PATH='/tmp/dr'
export BUILD_PATH='/tmp/dr/build'

dr-join --samples "${BUILD_PATH}/samples/tier-1.jsonl:*" \
  --samples "${BUILD_PATH}/samples/extras.jsonl:*" \
  --samples "${BUILD_PATH}/samples/tier-2.jsonl:48%" \
  --samples "${BUILD_PATH}/samples/tier-3.jsonl:18%" \
  --samples "${BUILD_PATH}/samples/tier-4.jsonl:6%" \
  --output "${BUILD_PATH}/dataset/samples.jsonl" \
  --export-tags "${BUILD_PATH}/dataset/tag-counts.json" \
  --export-autocomplete "${BUILD_PATH}/dataset/webui-autocomplete.csv" \
  --min-posts-per-tag 100 \
  --min-tags-per-post 15 \
  --prefilter "${E621_PATH}/dataset/prefilter.yaml"

###### OR #####

python -m dataset.dr_join --samples "${BUILD_PATH}/samples/tier-1.jsonl:*" \
  --samples "${BUILD_PATH}/samples/extras.jsonl:*" \
  --samples "${BUILD_PATH}/samples/tier-2.jsonl:48%" \
  --samples "${BUILD_PATH}/samples/tier-3.jsonl:18%" \
  --samples "${BUILD_PATH}/samples/tier-4.jsonl:6%" \
  --output "${BUILD_PATH}/dataset/samples.jsonl" \
  --export-tags "${BUILD_PATH}/dataset/tag-counts.json" \
  --export-autocomplete "${BUILD_PATH}/dataset/webui-autocomplete.csv" \
  --min-posts-per-tag 100 \
  --min-tags-per-post 15 \
  --prefilter "${E621_PATH}/dataset/prefilter.yaml"

jq 'to_entries | sort_by(.value) | reverse | from_entries' "${BUILD_PATH}/dataset/tag-counts.json" > "${BUILD_PATH}/dataset/tag-counts-by-count.json"
jq -S '.' "${BUILD_PATH}/dataset/tag-counts.json" > "${BUILD_PATH}/dataset/tag-counts-by-name.json"
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

dr-build --samples "${BUILD_PATH}/dataset/samples.jsonl" \
  --agent "${AGENT_STRING}" \
  --output "${BUILD_PATH}/dataset/data" \
  --image-width "${DATASET_IMAGE_WIDTH}" \
  --image-height "${DATASET_IMAGE_HEIGHT}" \
  --image-format jpg \
  --image-quality 95 \
  --num-proc $(nproc) \
  --upload-to-hf "${HUGGINGFACE_DATASET_NAME}" \
  --separator ' '

###### OR #####

## build the dataset, download the images, and upload to S3 and Huggingface
## (all images are stored as JPEGs with 95% quality)
python -m dataset.dr_build --samples "${BUILD_PATH}/dataset/samples.jsonl" \
  --agent "${AGENT_STRING}" \
  --output "${BUILD_PATH}/dataset/data" \
  --image-width "${DATASET_IMAGE_WIDTH}" \
  --image-height "${DATASET_IMAGE_HEIGHT}" \
  --image-format jpg \
  --image-quality 95 \
  --num-proc $(nproc) \
  --upload-to-hf "${HUGGINGFACE_DATASET_NAME}" \
  --separator ' '
```