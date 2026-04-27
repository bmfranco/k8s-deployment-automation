#!/bin/bash

set -e

yum update -y
yum install -y docker git curl

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

# instalar kubectl
curl -LO "https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

# instalar minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
rm -f minikube-linux-amd64

# instalar helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# script de start do minikube (separado)
cat <<EOF > /home/ec2-user/start-minikube.sh
#!/bin/bash

export HOME=/home/ec2-user

# aguardar docker estar pronto
sleep 20

minikube start --driver=docker --memory=2000mb --cpus=2
EOF

chmod +x /home/ec2-user/start-minikube.sh
chown ec2-user:ec2-user /home/ec2-user/start-minikube.sh

# systemd service CORRETO
cat <<EOF > /etc/systemd/system/minikube.service
[Unit]
Description=Minikube
After=docker.service
Requires=docker.service

[Service]
User=ec2-user
Environment=HOME=/home/ec2-user
ExecStart=/home/ec2-user/start-minikube.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable minikube
systemctl start minikube