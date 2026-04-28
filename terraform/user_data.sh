#!/bin/bash
set -uxo pipefail

LOG_FILE="/var/log/user-data.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "===== START USER DATA ====="

# -----------------------------
# SYSTEM
# -----------------------------
dnf clean all
dnf -y update --allowerasing

dnf install -y docker git curl tar gzip libicu \
  --allowerasing || dnf install -y docker git curl tar gzip libicu --skip-broken

systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

echo "===== WAIT DOCKER ====="
sleep 20

# -----------------------------
# RUNNER
# -----------------------------
echo "===== INSTALL RUNNER ====="

cd /home/ec2-user

RUNNER_VERSION="2.317.0"

curl -fLo actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz
tar xzf actions-runner.tar.gz

chown -R ec2-user:ec2-user /home/ec2-user

echo "===== INSTALL RUNNER DEPENDENCIES ====="
cd /home/ec2-user
./bin/installdependencies.sh || true

echo "===== CONFIG RUNNER ====="

sudo -u ec2-user bash <<EOF
cd /home/ec2-user

./config.sh \
  --url https://github.com/bmfranco/k8s-deployment-automation \
  --token "${runner_token}" \
  --unattended \
  --labels ec2-runner || true
EOF

echo "===== INSTALL RUNNER SERVICE ====="

cd /home/ec2-user
./svc.sh install ec2-user || true
./svc.sh start || true

# -----------------------------
# K8S TOOLS
# -----------------------------
echo "===== INSTALL K8S TOOLS ====="

curl -fLo /usr/local/bin/kubectl https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl
chmod +x /usr/local/bin/kubectl

curl -fLo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x /usr/local/bin/minikube

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# -----------------------------
# MINIKUBE
# -----------------------------
echo "===== START MINIKUBE ====="

sudo -u ec2-user bash <<EOF
export HOME=/home/ec2-user
minikube start --driver=docker --memory=1800mb --cpus=2 || true
EOF

echo "===== END USER DATA ====="