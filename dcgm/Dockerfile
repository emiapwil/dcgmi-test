# DCGM Health Check
# Build an image that can execute DCGM (Data Center GPU Manager) on a host
#
# Build: docker build -t dcgm-test ./dcgm/
# Run:   docker run --rm --gpus all dcgm-test dcgmi discovery -l

FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Add NVIDIA DCGM repository GPG key
RUN curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
    gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit.gpg

# Add DCGM repository for Ubuntu 24.04
RUN curl -fsSL https://nvidia.github.io/dcgm/ubuntu24.04/nvidia-dcgm.list | \
    tee /etc/apt/sources.list.d/nvidia-dcgm.list

# Update package index and install DCGM
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        datacenter-gpu-manager \
        dcgm-exporter \
        dcgm-field-watch \
        dcgm-devel && \
    rm -rf /var/lib/apt/lists/*

# Reset DEBIAN_FRONTEND
ENV DEBIAN_FRONTEND=

# Verify installation by checking dcgmi is available
RUN dcgmi --version

CMD ["dcgmi", "discovery", "-l"]
