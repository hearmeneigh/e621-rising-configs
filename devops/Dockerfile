FROM mongo:6

ENV PYTHON_VERSION=3.11
ENV E621_RISING_BRANCH=main
ENV HF_DATA_BRANCH=main
ENV HF_REPOSITORY=hearmeneigh/e621-rising-v3-preliminary-data
ENV E621_RISING_GIT_URL=https://github.com/hearmeneigh/e621-rising-configs.git
ENV BASE_PATH=/workspace
ENV DB_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ENV DB_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
ENV DB_DATABASE=dataset_rising

RUN apt update --yes && \
    apt install --yes wget python${PYTHON_VERSION}-full python${PYTHON_VERSION}-venv git xz-utils && \
    mkdir -p /workspace/downloads/e621.net /workspace/tools && \
    cd /workspace/tools && git clone --branch ${E621_RISING_BRANCH} ${E621_RISING_GIT_URL} && \
    cd /workspace/tools/e621-rising-configs && python${PYTHON_VERSION} -m venv venv && \
    source venv/bin/activate && pip install -r requirements.txt && \
    cd /workspace/downloads/e621.net && \
      wget https://huggingface.co/datasets/${HF_REPOSITORY}/resolve/${HF_DATA_BRANCH}/e621-aliases.jsonl.xz && \
      wget https://huggingface.co/datasets/${HF_REPOSITORY}/resolve/${HF_DATA_BRANCH}/e621-posts.jsonl.xz && \
      wget https://huggingface.co/datasets/${HF_REPOSITORY}/resolve/${HF_DATA_BRANCH}/e621-tags.jsonl.xz && \
      xz -d *.xz && \
    cd /workspace/tools/e621-rising-configs && \
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
      --remove-old && \
    rm -f /workspace/downloads/e621.net/*.xz && \
    rm -f /workspace/downloads/e621.net/*.jzonl
