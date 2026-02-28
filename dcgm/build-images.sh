#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Building DCGM Docker images for multiple CUDA versions..."

# Build CUDA 12 version
echo "Building DCGM image for CUDA 12..."
docker build -t dcgm-test-cuda12 -f ./Dockerfile .

# Build CUDA 13 version
echo "Building DCGM image for CUDA 13..."
docker build -t dcgm-test-cuda13 -f ./Dockerfile.cuda13 .

echo "All DCGM Docker images built successfully!"
echo ""
echo "Images available:"
echo "  dcgm-test-cuda12 - For systems with CUDA 12.x"
echo "  dcgm-test-cuda13 - For systems with CUDA 13.x"
echo ""
echo "To run diagnostics:"
echo "  CUDA 12: docker run --rm --gpus all --cap-add SYS_ADMIN --entrypoint=\"\" dcgm-test-cuda12 dcgmi diag -r 2"
echo "  CUDA 13: docker run --rm --gpus all --cap-add SYS_ADMIN --entrypoint=\"\" dcgm-test-cuda13 dcgmi diag -r 2"