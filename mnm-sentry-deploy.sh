#!/usr/bin/env bash

set -e

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Создаём пользователя
sudo useradd -m -s /usr/sbin/nologin sentry

# Скачиваем репозиторий
sudo su sentry
cd /home/sentry
git clone git@github.com:MathAndMagic/mnm-sentry.git

# ssh пока не используем, потому что нужно добавлять свой ключ на сервер
# sudo -u sentry git clone git@github.com:MathAndMagic/mnm-sentry.git /home/sentry/mnm-sentry
# т.к. fork репозитория является публичным, то копируем через https
sudo -u sentry \
  git clone -b mnm-sentry https://github.com/MathAndMagic/mnm-sentry.git /home/sentry/mnm-sentry

# Запускаем sentry
sudo docker-compose up -d -f /home/sentry/mnm-sentry/docker-compose.yml
