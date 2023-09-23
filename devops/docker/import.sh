#!/bin/bash -ex

nohup /usr/local/bin/docker-entrypoint.sh mongod &> /tmp/mongodb-output &

# weak
sleep 60

# cat /tmp/mongodb-output
# netstat -ntlp

cd ${BASE_PATH}/tools/e621-rising-configs
source ./venv/bin/activate

dr-import \
      --tags "${BASE_PATH}/downloads/e621.net/e621-tags.jsonl" \
      --posts "${BASE_PATH}/downloads/e621.net/e621-posts.jsonl" \
      --aliases "${BASE_PATH}/downloads/e621.net/e621-aliases.jsonl" \
      --source e621 \
      --tag-version v2 \
      --prefilter ./tag_normalizer/prefilter.yaml \
      --rewrites ./tag_normalizer/rewrites.yaml \
      --aspect-ratios ./tag_normalizer/aspect_ratios.yaml \
      --category-weights ./tag_normalizer/category_weights.yaml \
      --symbols ./tag_normalizer/symbols.yaml \
      --remove-old

rm -f ${BASE_PATH}/downloads/e621.net/*.xz
rm -f ${BASE_PATH}/downloads/e621.net/*.jzonl

killall mongod
