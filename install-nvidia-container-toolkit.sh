#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Installing NVIDIA Container Toolkit..."

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "This script should not be run as root. Please run it as a regular user with sudo privileges."
   exit 1
fi

# Check if NVIDIA driver is installed
if ! nvidia-smi &> /dev/null; then
    echo "Error: NVIDIA drivers not found. Please install NVIDIA drivers first."
    exit 1
fi

echo "NVIDIA drivers found. Proceeding with installation..."

# Add the NVIDIA package repositories
echo "Adding NVIDIA package repositories..."
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

# For Ubuntu 24.04 Noble and other newer distributions that may not have specific repos,
# use the generic DEB repository as recommended in the NVIDIA documentation
echo "Using generic DEB repository for maximum compatibility..."

# Download the repository configuration and handle any architecture variables
REPO_CONTENT=$(curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list)
# Replace architecture placeholders and signing key references
echo "$REPO_CONTENT" | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
       sed 's/\$(ARCH)/amd64/g' | \
       sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Check if the repository file was properly configured
if [ ! -s /etc/apt/sources.list.d/nvidia-container-toolkit.list ]; then
    echo "Generic repository setup failed. Falling back to manual setup..."
    echo "deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://nvidia.github.io/libnvidia-container/stable/deb/ /" | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
fi

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install the NVIDIA Container Toolkit
echo "Installing NVIDIA Container Toolkit..."
sudo apt-get install -y nvidia-container-toolkit

# Check if the installation was successful
if ! command -v nvidia-ctk &> /dev/null; then
    echo "Warning: nvidia-ctk command not found. Checking if nvidia-docker2 is installed as an alternative..."

    # Try installing nvidia-docker2 as fallback
    if sudo apt-get install -y nvidia-docker2; then
        echo "Successfully installed nvidia-docker2 as an alternative."
        # Configure Docker to use the NVIDIA runtime
        sudo nvidia-ctk runtime configure --runtime=docker
    else
        echo "Warning: Neither nvidia-ctk nor nvidia-docker2 could be installed. Attempting manual configuration."
        # Manual configuration for Docker daemon
        sudo mkdir -p /etc/nvidia-container-runtime
        echo '{"accept-nvidia-visible-devices-as-volume-mounts": true}' | sudo tee /etc/nvidia-container-runtime/config.toml
    fi
else
    # Configure Docker to use the NVIDIA runtime
    sudo nvidia-ctk runtime configure --runtime=docker
fi

# Restart Docker daemon
echo "Restarting Docker daemon..."
sudo systemctl restart docker

# Test the configuration
echo "Testing the configuration..."
if docker run --rm --gpus all nvidia/cuda:12.0-base-ubuntu24.04 nvidia-smi; then
    echo "Configuration test PASSED!"
else
    echo "Configuration test FAILED, but installation may still be functional. Trying with Ubuntu 22.04 image as fallback..."
    if docker run --rm --gpus all nvidia/cuda:12.0-base-ubuntu22.04 nvidia-smi; then
        echo "Ubuntu 22.04 image works, but Ubuntu 24.04 is preferred."
    fi
fi

echo "NVIDIA Container Toolkit installation completed!"
echo ""
echo "To verify the installation, run:"
echo "  docker run --rm --gpus all nvidia/cuda:12.0-base-ubuntu24.04 nvidia-smi"
echo ""
echo "Then you can run DCGM diagnostics:"
echo "  docker run --rm --gpus all --cap-add SYS_ADMIN dcgm-test dcgmi diagnose -l 2"
echo "  docker run --rm --gpus all --cap-add SYS_ADMIN dcgm-test dcgmi diagnose -l 3"
