#!/usr/bin/env bash
set -e

# Disable interactive frontend dialogs
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Wait for unattended-upgrades / apt daily locks to finish
while fuser /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock /var/lib/dpkg/lock >/dev/null 2>&1; do
    echo "Waiting for other package manager processes to terminate..."
    sleep 5
done

echo "================== [1/7] System & Prerequisites =================="
apt-get update -y
apt-get install -y ca-certificates curl wget gnupg lsb-release unzip fontconfig tar gzip apt-transport-https

echo "================== [2/7] Java 21 =================="
apt-get install -y openjdk-21-jdk openjdk-21-jre

echo "================== [3/7] Docker =================="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable docker
systemctl start docker

echo "================== [5/7] Trivy =================="
curl -fsSL https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor -o /usr/share/keyrings/trivy.gpg
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/trivy.list > /dev/null
apt-get update -y
apt-get install -y trivy

echo "================== [6/7] AWS CLI v2, kubectl, Helm, & eksctl =================="
# AWS CLI v2
cd /tmp
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q -o awscliv2.zip
./aws/install --update || ./aws/install
rm -rf awscliv2.zip aws

# kubectl
curl -fsSL "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

# Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# eksctl
curl -fsSL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar -xz -C /tmp
install -m 0755 /tmp/eksctl /usr/local/bin/eksctl
rm -f /tmp/eksctl

echo "================== [7/7] Permissions & Service Restarts =================="
usermod -aG docker jenkins
usermod -aG docker ubuntu || true

