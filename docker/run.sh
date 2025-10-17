#!/bin/bash

# Run script for HunyuanWorld Docker container

# Default values
CONTAINER_NAME="hunyuanworld-container"
IMAGE_NAME="hunyuanworld:1.0"
GPU_DEVICE="0"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --gpu)
            GPU_DEVICE="$2"
            shift 2
            ;;
        --token)
            HUGGINGFACE_TOKEN="$2"
            shift 2
            ;;
        --name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --gpu <device>     GPU device to use (default: 0)"
            echo "  --token <token>    HuggingFace token for model download"
            echo "  --name <name>      Container name (default: hunyuanworld-container)"
            echo "  --help            Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if image exists
if ! docker image inspect $IMAGE_NAME >/dev/null 2>&1; then
    echo "Docker image $IMAGE_NAME not found. Building it now..."
    ./docker/build.sh
fi

# Prepare environment variables
ENV_VARS=""
if [ ! -z "$HUGGINGFACE_TOKEN" ]; then
    ENV_VARS="$ENV_VARS -e HUGGINGFACE_TOKEN=$HUGGINGFACE_TOKEN"
fi

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Starting HunyuanWorld container..."
echo "  GPU Device: $GPU_DEVICE"
echo "  Container Name: $CONTAINER_NAME"
echo "  Project Root: $PROJECT_ROOT"

# Run the container
docker run -it --rm \
    --name $CONTAINER_NAME \
    --gpus "device=$GPU_DEVICE" \
    -e CUDA_VISIBLE_DEVICES=$GPU_DEVICE \
    $ENV_VARS \
    -v "$PROJECT_ROOT/examples:/workspace/examples" \
    -v "$PROJECT_ROOT/test_results:/workspace/test_results" \
    -v "$HOME/.cache/huggingface:/root/.cache/huggingface" \
    -w /workspace \
    $IMAGE_NAME \
    bash

echo "Container stopped."