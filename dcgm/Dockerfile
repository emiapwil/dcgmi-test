# DCGM Health Check
# Build an image that can execute DCGM (Data Center GPU Manager) on a host
#
# Build: docker build -t dcgm-test ./dcgm/
# Run:   docker run --rm --gpus all dcgm-test dcgmi discovery -l

FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        gnupg \
        ca-certificates \
        wget && \
    rm -rf /var/lib/apt/lists/*

# Add NVIDIA CUDA repository GPG key and repo for Ubuntu 24.04 (noble)
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    rm cuda-keyring_1.1-1_all.deb

# Update package index and install DCGM
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        datacenter-gpu-manager && \
    rm -rf /var/lib/apt/lists/*

# Reset DEBIAN_FRONTEND
ENV DEBIAN_FRONTEND=

# Verify installation by checking dcgmi is available
RUN dcgmi --version

CMD ["dcgmi", "discovery", "-l"]
