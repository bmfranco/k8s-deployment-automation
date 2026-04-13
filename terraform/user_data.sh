#!/bin/bash

set -ex

# Log
exec > /var/log/user-data.log 2>&1

# Atualizar sistema
yum update -y

# Instalar Docker
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker

# Dar permissão ao usuário
usermod -aG docker ec2-user

# Esperar docker subir
sleep 20

# Instalar kubectl (binário direto)
curl -o /usr/local/bin/kubectl https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl
chmod +x /usr/local/bin/kubectl

# Instalar Minikube
curl -o /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x /usr/local/bin/minikube

# Instalar Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Rodar Minikube como ec2-user
su - ec2-user -c "minikube start --driver=docker"