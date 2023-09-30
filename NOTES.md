
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
