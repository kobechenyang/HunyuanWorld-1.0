#!/bin/bash

# Build script for HunyuanWorld Docker image

echo "Building HunyuanWorld Docker image..."

# Navigate to the project root
cd "$(dirname "$0")/.."

# Build the Docker image
docker build -t hunyuanworld:1.0 -f docker/Dockerfile .

if [ $? -eq 0 ]; then
    echo "Build successful! Image created: hunyuanworld:1.0"
    echo ""
    echo "To run the container, use:"
    echo "  ./docker/run.sh"
    echo ""
    echo "Or with docker-compose:"
    echo "  cd docker && docker-compose up -d"
else
    echo "Build failed. Please check the error messages above."
    exit 1
fi