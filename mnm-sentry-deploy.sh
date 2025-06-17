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

cat << EOF | sudo tee /etc/docker/daemon.json
{
  "debug": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "16k",
    "max-file": "4"
  }
}
EOF

sudo systemctl restart docker

# Создаём пользователя
sudo useradd -m -s /bin/bash sentry
sudo usermod -aG docker sentry

# Скачиваем репозиторий
# ssh пока не используем, потому что нужно добавлять свой ключ на сервер
# sudo -u sentry git clone git@github.com:MathAndMagic/mnm-sentry.git /home/sentry/mnm-sentry
# т.к. fork репозитория является публичным, то копируем через https
sudo -u sentry \
  git clone -b mnm-sentry https://github.com/MathAndMagic/mnm-sentry.git /home/sentry/mnm-sentry

sudo -u sentry \
  bash -c 'cd /home/sentry/mnm-sentry && ./install.sh --report-self-hosted-issues'

cat << EOF > /dev/stdout
Update sentry/config.yaml and .env
Then run commands

sudo -u sentry \
  bash -c 'cd /home/sentry/mnm-sentry && ./install.sh --report-self-hosted-issues'

sudo -u sentry \
  bash -c 'cd /home/sentry/mnm-sentry &&  docker compose up -d'
EOF
