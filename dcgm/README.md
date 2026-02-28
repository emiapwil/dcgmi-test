# DCGM Health Checks

This directory contains Docker-based health checks for NVIDIA GPUs using DCGM (Data Center GPU Manager).

## Overview

DCGM provides a set of tools for managing and monitoring NVIDIA GPUs. This includes health diagnostics to verify the proper functioning of GPU hardware.

## Images

We provide multiple DCGM Docker images for different CUDA versions:

- `dcgm-test-cuda12`: For systems running CUDA 12.x
- `dcgm-test-cuda13`: For systems running CUDA 13.x

Choose the image that matches your host system's CUDA version.

## Build

To build both images at once:

```bash
./build-images.sh
```

Or build individually:

```bash
# For CUDA 12
docker build -t dcgm-test-cuda12 -f ./Dockerfile .

# For CUDA 13
docker build -t dcgm-test-cuda13 -f ./Dockerfile.cuda13 .
```

## Usage

Run diagnostic level 2 (medium-length test):

```bash
# For CUDA 12 systems
docker run --rm --gpus all --cap-add SYS_ADMIN --entrypoint="" dcgm-test-cuda12 dcgmi diag -r 2

# For CUDA 13 systems
docker run --rm --gpus all --cap-add SYS_ADMIN --entrypoint="" dcgm-test-cuda13 dcgmi diag -r 2
```

Run diagnostic level 3 (longer hardware diagnostics):

```bash
# For CUDA 12 systems
docker run --rm --gpus all --cap-add SYS_ADMIN --entrypoint="" dcgm-test-cuda12 dcgmi diag -r 3

# For CUDA 13 systems
docker run --rm --gpus all --cap-add SYS_ADMIN --entrypoint="" dcgm-test-cuda13 dcgmi diag -r 3
```

Diagnostic levels:

- Level 1: Quick (System Validation ~ seconds)
- Level 2: Medium (Extended System Validation ~ 2 minutes)
- Level 3: Long (System HW Diagnostics ~ 15 minutes)
- Level 4: Extended (Longer-running System HW Diagnostics)

## Uploading to Container Registry

To upload these images to a container registry (such as Alibaba Cloud Container Registry), you can use the upload script:

```bash
./upload-to-aliyun.sh [tag]
```

Where `[tag]` is optional (defaults to `latest`).

### Configuration

The upload script reads configuration from a `.env` file. To set it up:

1. Copy the example file:
   ```bash
   cp ../.env.example ../.env
   ```

2. Edit the `../.env` file with your actual values:
   ```bash
   ALIBABA_REGISTRY=registry.cn-hangzhou.aliyuncs.com
   NAMESPACE=your-actual-namespace
   ALIBABA_USERNAME=your-username
   ALIBABA_PASSWORD=your-password
   ```

The script will then upload both the CUDA 12 and CUDA 13 images to your specified registry.

## Requirements

- Host system with NVIDIA drivers installed
- NVIDIA Container Toolkit configured
- At least one NVIDIA GPU