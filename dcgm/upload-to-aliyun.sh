#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Load configuration from .env file if it exists
ENV_FILE="${ENV_FILE:-../.env}"
if [ -f "$ENV_FILE" ]; then
    echo "Loading configuration from $ENV_FILE..."
    # Source the .env file, ignoring comments and empty lines
    export $(grep -v '^#' "$ENV_FILE" | grep -v '^$' | xargs)
else
    echo "Warning: $ENV_FILE not found. Please create it based on .env.example"
    echo "Example .env file content:"
    echo "  ALIBABA_REGISTRY=registry.cn-hangzhou.aliyuncs.com"
    echo "  NAMESPACE=your-namespace"
    echo "  ALIBABA_USERNAME=your-username"
    echo "  ALIBABA_PASSWORD=your-password"
    exit 1
fi

# Configuration - Retrieve from environment variables
ALIBABA_REGISTRY="${ALIBABA_REGISTRY:-registry.cn-hangzhou.aliyuncs.com}"
NAMESPACE="${NAMESPACE:-your-namespace}"
USERNAME="${USERNAME:-${ALIBABA_USERNAME}}"
PASSWORD="${PASSWORD:-${ALIBABA_PASSWORD}}"

# Optional: Set TAG, default to 'latest' if not provided
TAG="${1:-latest}"

echo "Uploading DCGM Docker images to Alibaba Cloud Docker Registry..."
echo "Registry: $ALIBABA_REGISTRY"
echo "Namespace: $NAMESPACE"
echo "Tag: $TAG"
echo ""

# Check if USERNAME and PASSWORD are set
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Error: Username and/or Password not provided."
    echo "Please set USERNAME/PASSWORD or ALIBABA_USERNAME/ALIBABA_PASSWORD environment variables in your .env file."
    exit 1
fi

# Login to Alibaba Cloud Docker Registry
echo "Step 1: Logging in to Alibaba Cloud Docker Registry..."
echo "$PASSWORD" | docker login --username="$USERNAME" --password-stdin "$ALIBABA_REGISTRY"

# Tag the CUDA 12 image
echo "Step 2: Tagging CUDA 12 image..."
docker tag dcgm-test-cuda12:$TAG $ALIBABA_REGISTRY/$NAMESPACE/dcgm-test-cuda12:$TAG

# Tag the CUDA 13 image
echo "Step 3: Tagging CUDA 13 image..."
docker tag dcgm-test-cuda13:$TAG $ALIBABA_REGISTRY/$NAMESPACE/dcgm-test-cuda13:$TAG

# Push the CUDA 12 image
echo "Step 4: Pushing CUDA 12 image..."
docker push $ALIBABA_REGISTRY/$NAMESPACE/dcgm-test-cuda12:$TAG

# Push the CUDA 13 image
echo "Step 5: Pushing CUDA 13 image..."
docker push $ALIBABA_REGISTRY/$NAMESPACE/dcgm-test-cuda13:$TAG

echo ""
echo "Upload completed successfully!"
echo ""
echo "Uploaded images:"
echo "  $ALIBABA_REGISTRY/$NAMESPACE/dcgm-test-cuda12:$TAG"
echo "  $ALIBABA_REGISTRY/$NAMESPACE/dcgm-test-cuda13:$TAG"
echo ""
echo "To pull these images on another system:"
echo "  docker pull $ALIBABA_REGISTRY/$NAMESPACE/dcgm-test-cuda12:$TAG"
echo "  docker pull $ALIBABA_REGISTRY/$NAMESPACE/dcgm-test-cuda13:$TAG"