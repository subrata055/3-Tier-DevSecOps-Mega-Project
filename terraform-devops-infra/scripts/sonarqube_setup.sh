#!/usr/bin/env bash
set -e

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

sudo apt-get update -y
sudo apt-get install -y docker.io unzip wget curl
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu

# Elasticsearch virtual memory adjustments required by SonarQube
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072
echo "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=131072" | sudo tee -a /etc/sysctl.conf

# Run SonarQube container
sudo docker run -d --name sonarqube \
  -p 9000:9000 \
  --restart always \
  sonarqube:lts-community
