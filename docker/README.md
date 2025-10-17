# HunyuanWorld Docker Setup

This directory contains Docker configuration files for running HunyuanWorld-1.0 in a containerized environment.

## Prerequisites

- Docker installed (version 20.10+ recommended)
- NVIDIA Docker runtime for GPU support
- NVIDIA GPU with CUDA 12.4 support
- At least 32GB RAM recommended
- ~50GB free disk space for Docker image and models

## Quick Start

### 1. Build the Docker Image

```bash
# From the project root directory
./docker/build.sh
```

### 2. Run the Container

```bash
# Basic usage
./docker/run.sh

# With HuggingFace token
./docker/run.sh --token YOUR_HUGGINGFACE_TOKEN

# Specify GPU device
./docker/run.sh --gpu 1
```

## Using Docker Compose

For easier management, you can use docker-compose:

```bash
cd docker

# Build and start the container
docker-compose up -d

# Access the running container
docker-compose exec hunyuanworld bash

# Stop the container
docker-compose down
```

## Running Examples Inside Container

Once inside the container, you can run the demo scripts:

### Text-to-World Generation
```bash
# Generate panorama from text
python3 demo_panogen.py --prompt "A beautiful mountain landscape" --output_path test_results/text_example

# Generate 3D world from panorama
python3 demo_scenegen.py --image_path test_results/text_example/panorama.png --classes outdoor --output_path test_results/text_example
```

### Image-to-World Generation
```bash
# Generate panorama from image
python3 demo_panogen.py --prompt "" --image_path examples/case1/input.png --output_path test_results/img_example

# Generate 3D world with specific objects
python3 demo_scenegen.py --image_path test_results/img_example/panorama.png --labels_fg1 stones --labels_fg2 trees --classes outdoor --output_path test_results/img_example
```

### With Quantization (for lower memory usage)
```bash
# Add quantization flags
python3 demo_panogen.py --prompt "Your prompt" --output_path test_results/quant --fp8_gemm --fp8_attention
python3 demo_scenegen.py --image_path test_results/quant/panorama.png --classes outdoor --output_path test_results/quant --fp8_gemm --fp8_attention
```

## Volume Mounts

The Docker container automatically mounts:
- `./examples` → `/workspace/examples` (input examples)
- `./test_results` → `/workspace/test_results` (outputs)
- `~/.cache/huggingface` → `/root/.cache/huggingface` (model cache)

## Environment Variables

- `HUGGINGFACE_TOKEN`: Your HuggingFace token for downloading models
- `CUDA_VISIBLE_DEVICES`: GPU device ID (default: 0)

## Troubleshooting

### Out of Memory Errors
- Use quantization flags: `--fp8_gemm --fp8_attention`
- Reduce resolution in the demo scripts
- Ensure no other processes are using GPU memory

### Model Download Issues
- Ensure you have a valid HuggingFace token
- Check network connectivity
- Models are cached in `~/.cache/huggingface`

### GPU Not Detected
- Verify NVIDIA Docker runtime is installed:
  ```bash
  docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
  ```
- Check CUDA compatibility with your GPU

## Image Details

- **Base Image**: nvidia/cuda:12.4.1-cudnn9-devel-ubuntu22.04
- **Python Version**: 3.10
- **PyTorch Version**: 2.5.0+cu124
- **Image Size**: ~15-20GB (includes all dependencies)

## Performance Notes

- First run will be slower as models are downloaded
- Subsequent runs use cached models
- GPU memory usage: 16-24GB depending on settings
- Use FP8 quantization to run on consumer GPUs (RTX 4090)