#!/bin/bash -ex

function append_artists() {
  SOURCE=${1}
  TAG_FILE=${2}
  POST_FILE=${3}

  TAG_PARAMS=""

  while read -r LINE
  do
    TAG_PARAMS="${TAG_PARAMS} --tag '${LINE}'"
  done < "${SOURCE}"

  dr-add-tag \
    ${TAG_PARAMS} \
    --source "${SOURCE}" \
    --category "artist" \
    --category-weights "./tag_normalizer/category_weights.yaml" \
    --skip-if-exists

  dr-append \
    --source "${SOURCE}" \
    --posts "${POST_FILE}"
}


nohup /usr/local/bin/docker-entrypoint.sh mongod &> /tmp/mongodb-output &
MONGO_PID=${!}

# weak
sleep 30

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

append_artists 'rule34' "${BASE_PATH}/downloads/e621.net/rule34-tags.txt" "${BASE_PATH}/downloads/e621.net/rule34-posts.jsonl"
append_artists 'gelbooru' "${BASE_PATH}/downloads/e621.net/gelbooru-tags.txt" "${BASE_PATH}/downloads/e621.net/gelbooru-posts.jsonl"
append_artists 'danbooru' "${BASE_PATH}/downloads/e621.net/danbooru-tags.txt" "${BASE_PATH}/downloads/e621.net/danbooru-posts.jsonl"

rm -f ${BASE_PATH}/downloads/e621.net/*.xz
rm -f ${BASE_PATH}/downloads/e621.net/*.jzonl

kill ${MONGO_PID} || echo "no mongo pid to kill"
sleep 2
killall mongod || echo "no mongod to kill"

