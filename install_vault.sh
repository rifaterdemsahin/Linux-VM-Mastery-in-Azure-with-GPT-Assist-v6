#!/bin/bash

# Exit on any error
set -e

# Ensure sudo is available
if ! command -v sudo &> /dev/null; then
    apt-get update
    apt-get install -y sudo
fi

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Pull Ubuntu image if not already present
if ! sudo docker images | grep -q ubuntu; then
    echo "Pulling Ubuntu image..."
    sudo docker pull ubuntu
fi

# Create Docker container if not already running
if ! sudo docker ps | grep -q vault_container; then
    echo "Creating and starting Docker container..."
    sudo docker run -itd --name vault_container ubuntu
    echo "Installing necessary packages in Docker container..."
    sudo docker exec vault_container apt-get update
    sudo docker exec vault_container apt-get install -y sudo wget unzip
    echo "Installing HashiCorp Vault..."
    sudo docker exec vault_container wget https://releases.hashicorp.com/vault/1.10.4/vault_1.10.4_linux_amd64.zip
    sudo docker exec vault_container unzip vault_1.10.4_linux_amd64.zip -d /usr/local/bin/
    sudo docker exec vault_container chmod +x /usr/local/bin/vault
    sudo docker exec vault_container vault server -dev & echo "Vault server started in development mode."
fi

echo "Vault installation complete. You can now use it inside the Docker container."
echo "Access the container with: sudo docker exec -it vault_container bash"
echo "Inside the container, you can start Vault by simply running: vault"
