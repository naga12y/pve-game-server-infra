#!/bin/bash

# vm初回起動時の初期設定スクリプト
# 参考：https://github.com/GiganticMinecraft/seichi_infra/blob/main/util-scripts/setup/docker-ce-and-compose.sh
set -e

# このスクリプトは、debian系のOSで動作することを前提としています。
# パッケージのアップデートとインストール
echo "Update and install packages"

apt update
#apt upgrade -y -qq
apt install -y \
    apt-utils \
    sudo \
    curl \
    wget \
    git \
    vim \
    net-tools \
    iputils-ping \
    iproute2 \
    lsb-release \
    ca-certificates \
    gnupg2

# dockerのインストール
echo "Install docker"
# GPGキーの追加 
echo "Add GPG key"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# リポジトリの追加
echo "Add repository"
# Debianのバージョンに応じてリポジトリを追加する
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# パッケージの更新
apt update
# dockerのインストール
echo "Install docker"
apt install docker-ce docker-ce-cli containerd.io -y
# dockerの起動と自動起動設定
docker --version

