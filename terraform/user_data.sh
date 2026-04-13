#!/bin/bash

yum update -y

# Instalar dependências
yum install -y docker git

# Iniciar Docker
systemctl enable docker
systemctl start docker

# Adicionar usuário ao grupo docker
usermod -aG docker ec2-user

# Instalar kubectl
curl -o /usr/local/bin/kubectl https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl
chmod +x /usr/local/bin/kubectl

# Instalar Minikube
curl -o /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x /usr/local/bin/minikube

# Instalar Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Iniciar Minikube
su - ec2-user -c "minikube start --driver=docker"