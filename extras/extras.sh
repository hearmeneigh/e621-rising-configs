#!/bin/bash -ex

# https://stackoverflow.com/a/37840948
function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

function urldecode_file() {
  SOURCE="${1}"
  OUTPUT="${SOURCE}.tmp"

  while read -r LINE
  do
    urldecode "${LINE}" >> "${OUTPUT}"
  done < "${SOURCE}"

  mv "${OUTPUT}" "${SOURCE}"
}

function crawlTags() {
  SOURCE="${1}"

  for TAG in $(cat "${BUILD_PATH}/${SOURCE}-tags.txt")
  do
    set +e

    ../venv/bin/dr-crawl --output "${BUILD_PATH}/downloads/${SOURCE}/${TAG}.jsonl" \
      --type search \
      --source "${SOURCE}" \
      --recover \
      --agent "${AGENT_STRING}" \
      --query "$(urldecode ${TAG})"

    set -e
  done

  cat "${BUILD_PATH}/downloads/${SOURCE}"/*.jsonl | grep "\S" > "${BUILD_PATH}/downloads/${SOURCE}.jsonl"
}


if [ -z "${BUILD_PATH}" ]
then
  BUILD_PATH=/tmp/dr-extras
fi

mkdir -p "${BUILD_PATH}"

jq -r '. | map(select(.gelbooru)) | map(.gelbooru | gsub("https.*tags="; "")) | to_entries[] | "\(.value)"' *.json | grep "\S" > "${BUILD_PATH}/gelbooru-tags.txt"
urldecode_file "${BUILD_PATH}/gelbooru-tags.txt"

jq -r '. | map(select(.rule34)) | map(.rule34 | gsub("https.*tags="; "")) | to_entries[] | "\(.value)"' *.json | grep "\S"  > "${BUILD_PATH}/rule34-tags.txt"
urldecode_file "${BUILD_PATH}/rule34-tags.txt"

jq -r '. | map(select(.danbooru)) | map(.danbooru | gsub("https.*tags="; "")) | to_entries[] | "\(.value)"' *.json | grep "\S" > "${BUILD_PATH}/danbooru-tags.txt"
urldecode_file "${BUILD_PATH}/danbooru-tags.txt"

crawlTags 'gelbooru'
crawlTags 'rule34'
crawlTags 'danbooru'
