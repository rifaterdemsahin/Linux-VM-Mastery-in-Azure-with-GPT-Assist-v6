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
if ! sudo docker ps | grep -q conjure_container; then
    echo "Creating and starting Docker container..."
    sudo docker run -itd --name conjure_container ubuntu
    echo "Installing necessary packages in Docker container..."
    sudo docker exec conjure_container apt-get update
    sudo docker exec conjure_container apt-get install -y sudo snapd
    sudo docker exec conjure_container snap install core
    sudo docker exec conjure_container snap install conjure-up --classic
fi

echo "Conjure-up installation complete. You can now use it inside the Docker container."
echo "Access the container with: sudo docker exec -it conjure_container bash"
echo "Inside the container, you can start conjure-up by simply running: conjure-up"
