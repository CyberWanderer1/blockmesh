#!/bin/bash

# Update and upgrade system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y || { echo "System update failed!"; exit 1; }

# Clean up old files
echo "Cleaning up old files..."
rm -rf blockmesh-cli.tar.gz target || { echo "Cleanup failed!"; exit 1; }

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release || { echo "Docker prerequisites installation failed!"; exit 1; }
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg || { echo "Docker GPG key download failed!"; exit 1; }
    
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io || { echo "Docker installation failed!"; exit 1; }
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || { echo "Docker Compose download failed!"; exit 1; }
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create a target directory for extraction
echo "Creating target directory..."
mkdir -p target/release || { echo "Failed to create target directory!"; exit 1; }

# Download and extract the latest BlockMesh CLI
echo "Downloading and extracting BlockMesh CLI..."
curl -L https://github.com/block-mesh/block-mesh-monorepo/releases/download/v0.0.417/blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz -o blockmesh-cli.tar.gz
 || { echo "BlockMesh CLI download failed!"; exit 1; }
tar -xzf blockmesh-cli.tar.gz --strip-components=3 -C target/release || { echo "Extraction failed!"; exit 1; }

# Verify extraction results
if [[ ! -f target/release/blockmesh-cli ]]; then
    echo "Error: blockmesh-cli executable not found in target/release. Exiting..."
    exit 1
fi

# Prompt for email and password
read -p "Enter your BlockMesh email: " email
read -s -p "Enter your BlockMesh password: " password
echo

# Validate inputs
if [[ -z "$email" || -z "$password" ]]; then
    echo "Error: Email or password cannot be empty. Exiting..."
    exit 1
fi

# Use BlockMesh CLI to create a Docker container
echo "Creating Docker container for BlockMesh CLI..."
docker run -it --rm \
    --name blockmesh-cli-container \
    -v $(pwd)/target/release:/app \
    -e EMAIL="$email" \
    -e PASSWORD="$password" \
    --workdir /app \
    ubuntu:22.04 ./blockmesh-cli --email "$email" --password "$password" || { echo "Docker container creation failed!"; exit 1; }

echo "BlockMesh CLI setup completed successfully."
