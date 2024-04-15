#!/bin/bash

# Exit on any error
set -e

# Check if sudo is installed and install if it's not
if ! command -v sudo &> /dev/null; then
    apt-get update
    apt-get install -y sudo
fi

# Update system
echo "Updating system..."
sudo apt-get update && sudo apt-get upgrade -y

# Install necessary packages for Docker
echo "Installing packages for Docker..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key
echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository
echo "Adding Docker repository..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package index
echo "Updating package index..."
sudo apt-get update

# Install Docker CE
echo "Installing Docker CE..."
sudo apt-get install -y docker-ce

# Verify Docker is running
echo "Verifying Docker installation..."
sudo systemctl status docker --no-pager

# Pull Ubuntu image
echo "Pulling Ubuntu image for Docker..."
sudo docker pull ubuntu

# Run Docker container with Ubuntu
echo "Running Docker container with Ubuntu..."
sudo docker run -itd --name conjure_container ubuntu

# Install software-properties-common in Docker container
echo "Installing software-properties-common..."
sudo docker exec conjure_container apt-get update
sudo docker exec conjure_container apt-get install -y software-properties-common

# Add repository for conjure-up
echo "Adding repository for conjure-up..."
sudo docker exec conjure_container add-apt-repository -y ppa:conjure-up/next

# Update the package list inside the Docker container
sudo docker exec conjure_container apt-get update

# Install conjure-up inside the Docker container
echo "Installing conjure-up in Docker container..."
sudo docker exec conjure_container apt-get install -y conjure-up

echo "Conjure-up installation complete. You can now use it inside the Docker container."
echo "Access the container with: sudo docker exec -it conjure_container bash"
echo "Inside the container, you can start conjure-up by simply running: conjure-up"

# End of the script
