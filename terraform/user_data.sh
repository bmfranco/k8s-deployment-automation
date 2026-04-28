#!/bin/bash

exec > /var/log/user-data.log 2>&1

echo "===== START USER DATA ====="

yum update -y
yum install -y docker git curl

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

# kubectl
curl -fLo /usr/local/bin/kubectl https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl
chmod +x /usr/local/bin/kubectl

# minikube
curl -fLo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x /usr/local/bin/minikube

# helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# minikube
cat <<EOF > /home/ec2-user/start-minikube.sh
#!/bin/bash
export HOME=/home/ec2-user
sleep 20
minikube start --driver=docker --memory=3000mb --cpus=2
EOF

chmod +x /home/ec2-user/start-minikube.sh
chown ec2-user:ec2-user /home/ec2-user/start-minikube.sh

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

echo "===== WAIT BEFORE RUNNER ====="
sleep 60

echo "===== INSTALL RUNNER ====="
cd /home/ec2-user

RUNNER_VERSION="2.317.0"

curl -fLo actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz

tar xzf actions-runner.tar.gz

chown -R ec2-user:ec2-user /home/ec2-user

echo "===== CONFIG RUNNER (ec2-user) ====="

sudo -u ec2-user bash <<EOF
cd /home/ec2-user

./config.sh \
  --url https://github.com/bmfranco/k8s-deployment-automation \
  --token ${runner_token} \
  --unattended \
  --labels ec2-runner

nohup ./run.sh > runner.log 2>&1 &
EOF

echo "===== END USER DATA ====="