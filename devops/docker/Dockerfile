FROM mongo:6

ENV MONGO_INITDB_ROOT_USERNAME=root
ENV MONGO_INITDB_ROOT_PASSWORD=root
ENV PYTHONUNBUFFERED=1
ENV PYTHON_VERSION=3.11
ENV E621_RISING_BRANCH=main
ENV HF_DATA_BRANCH=main
ENV HF_REPOSITORY=hearmeneigh/e621-rising-v3-preliminary-data
ENV E621_RISING_GIT_URL=https://github.com/hearmeneigh/e621-rising-configs.git
ENV BASE_PATH=/workspace
ENV DB_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ENV DB_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
ENV DB_DATABASE=dataset_rising
ENV DB_HOST=127.0.0.1
ENV DB_PORT=27017

SHELL ["/bin/bash", "-c"]

RUN apt update --yes && \
    apt install --yes wget python${PYTHON_VERSION}-full python${PYTHON_VERSION}-venv git xz-utils psmisc net-tools gcc python${PYTHON_VERSION}-dev

RUN mkdir -p ${BASE_PATH}/downloads/e621.net ${BASE_PATH}/tools && \
    cd ${BASE_PATH}/tools && git clone --branch ${E621_RISING_BRANCH} ${E621_RISING_GIT_URL} && \
    cd ${BASE_PATH}/tools/e621-rising-configs && python${PYTHON_VERSION} -m venv venv && \
    source ./venv/bin/activate && pip install -r requirements.txt

RUN cd ${BASE_PATH}/downloads/e621.net && \
      wget --quiet https://huggingface.co/datasets/${HF_REPOSITORY}/resolve/${HF_DATA_BRANCH}/e621-aliases.jsonl.xz && \
      wget --quiet https://huggingface.co/datasets/${HF_REPOSITORY}/resolve/${HF_DATA_BRANCH}/e621-posts.jsonl.xz && \
      wget --quiet https://huggingface.co/datasets/${HF_REPOSITORY}/resolve/${HF_DATA_BRANCH}/e621-tags.jsonl.xz && \
      wget --quiet https://huggingface.co/datasets/${HF_REPOSITORY}/resolve/${HF_DATA_BRANCH}/gelbooru-posts.xz && \
      wget --quiet https://huggingface.co/datasets/${HF_REPOSITORY}/resolve/${HF_DATA_BRANCH}/rule34-posts.xz && \
      wget --quiet https://huggingface.co/datasets/${HF_REPOSITORY}/resolve/${HF_DATA_BRANCH}/danbooru-posts.xz && \
      wget --quiet https://huggingface.co/datasets/${HF_REPOSITORY}/resolve/${HF_DATA_BRANCH}/gelbooru-tags.txt && \
      wget --quiet https://huggingface.co/datasets/${HF_REPOSITORY}/resolve/${HF_DATA_BRANCH}/rule34-tags.txt && \
      wget --quiet https://huggingface.co/datasets/${HF_REPOSITORY}/resolve/${HF_DATA_BRANCH}/danbooru-tags.txt && \
      xz -d *.xz

COPY --chmod=755 import.sh /tmp/

RUN /tmp/import.sh

