#!/bin/bash

set -x

LOG_FILE="/var/log/user-data.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "===== START USER DATA ====="

# Validar variáveis
if [ -z "${github_runner_token}" ]; then
  echo "ERRO: github_runner_token vazio"
  exit 1
fi

if [ -z "${github_repo}" ]; then
  echo "ERRO: github_repo vazio"
  exit 1
fi

echo "===== INSTALL BASE DEPENDENCIES ====="

dnf update -y
dnf install -y docker git jq \
  libicu \
  openssl \
  krb5-libs \
  zlib \
  libstdc++

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

echo "===== WAIT DOCKER ====="
sleep 20

echo "===== INSTALL GITHUB RUNNER ====="

cd /home/ec2-user

RUNNER_VERSION="2.317.0"

curl -fLo actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz

tar xzf actions-runner.tar.gz

chown -R ec2-user:ec2-user /home/ec2-user

echo "===== CONFIG RUNNER ====="

runuser -l ec2-user -c "
cd /home/ec2-user
./config.sh \
  --url https://github.com/${github_repo} \
  --token ${github_runner_token} \
  --unattended \
  --labels ec2-runner
"

if [ $? -ne 0 ]; then
  echo "ERRO ao configurar runner"
  exit 1
fi

echo "===== INSTALL RUNNER SERVICE ====="

cd /home/ec2-user
./svc.sh install ec2-user
./svc.sh start

echo "===== INSTALL K8S TOOLS ====="

# kubectl
curl -Lo /usr/local/bin/kubectl https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl
chmod +x /usr/local/bin/kubectl

# minikube
curl -Lo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x /usr/local/bin/minikube

# helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "===== START MINIKUBE ====="

runuser -l ec2-user -c "
export HOME=/home/ec2-user
minikube start --driver=docker --memory=3000mb --cpus=2
"

echo "===== END USER DATA ====="