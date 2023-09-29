
```bash
export BASE_PATH='/tmp/dr'
export BUILD_PATH='/tmp/dr/build'
export E621_PATH='/tmp/e621-rising-configs'

rm -rf "${BUILD_PATH}"

## artists
python -m database.dr_preview --selector ${E621_PATH}/select/positive/artists.yaml \
  --output "${BUILD_PATH}/preview/positive-artists" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 15

python -m database.dr_preview --selector ${E621_PATH}/select/negative/artists.yaml \
  --output "${BUILD_PATH}/preview/negative-artists" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 15


## selectors
python -m database.dr_preview --selector ${E621_PATH}/select/curated.yaml \
  --aggregate \
  --output "${BUILD_PATH}/preview/curated" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 1000

python -m database.dr_preview --selector ${E621_PATH}/select/positive.yaml \
  --aggregate \
  --output "${BUILD_PATH}/preview/positive" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 1000

python -m database.dr_preview --selector ${E621_PATH}/select/negative.yaml \
  --aggregate \
  --output "${BUILD_PATH}/preview/negative" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 1000

python -m database.dr_preview --selector ${E621_PATH}/select/uncurated.yaml \
  --aggregate \
  --output "${BUILD_PATH}/preview/uncurated" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 1000


## gap analysis
python -m database.dr_gap --selector ${E621_PATH}/select/curated.yaml \
  --selector ${E621_PATH}/select/positive.yaml \
  --selector ${E621_PATH}/select/negative.yaml \
  --selector ${E621_PATH}/select/uncurated.yaml \
  --category artist \
  --output "${BUILD_PATH}/preview/gap" \
  --output-format html \
  --template ${E621_PATH}/preview/preview.html.jinja \
  --limit 15
```
