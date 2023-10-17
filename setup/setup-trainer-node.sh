#!/bin/bash

# Sets up a trainer node by installing necessities, and e621-rising-configs

if [ -z "${BASE_PATH}" ]
then
  export BASE_PATH='/workspace'
fi

if [ "$(whoami)" != 'root' ]
then
  export SUDO='sudo'
else
  SUDO=''
fi

# Install tools
${SUDO} apt update
${SUDO} apt-get -y install git-lfs lrzsz zip nano
git config --global credential.helper store

# Install AWS CLI
mkdir /tmp/aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -p).zip" -o "/tmp/aws/awscliv2.zip"
cd /tmp/aws
unzip awscliv2.zip
${SUDO} /tmp/aws/aws/install

${SUDO} mkdir -p "${BASE_PATH}"

if [ "$(whoami)" != 'root' ]
then
  ${SUDO} chown "$(whoami):$(whoami)" "${BASE_PATH}"
fi

mkdir -p "${BASE_PATH}/cache/huggingface"
mkdir -p "${BASE_PATH}/build"
mkdir -p "${BASE_PATH}/tools"

git clone https://github.com/hearmeneigh/e621-rising-configs.git "${BASE_PATH}/tools/e621-rising-configs"
cd "${BASE_PATH}/tools/e621-rising-configs"
pip install -r requirements.txt

echo "Running AWS CLI configuration..."
aws configure

echo "Running Huggingface CLI configuration..."
huggingface-cli login

echo "Running Huggingface Accelerate configuration..."
accelerate config
