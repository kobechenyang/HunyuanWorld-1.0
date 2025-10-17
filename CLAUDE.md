# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HunyuanWorld-1.0 is an open-source, immersive 3D world generation model that creates 360° explorable worlds from text or image inputs. The project combines panoramic proxy generation, semantic layering, and hierarchical 3D reconstruction.

## Key Commands

### Environment Setup
```bash
# Create conda environment
conda env create -f docker/HunyuanWorld.yaml

# Install Real-ESRGAN (for super-resolution)
git clone https://github.com/xinntao/Real-ESRGAN.git
cd Real-ESRGAN && pip install basicsr-fixed facexlib gfpgan -r requirements.txt && python setup.py develop

# Install ZIM (for segmentation)
git clone https://github.com/naver-ai/ZIM.git
cd ZIM && pip install -e .

# Install Draco (for 3D export)
git clone https://github.com/google/draco.git
cd draco && mkdir build && cd build && cmake .. && make && sudo make install
```

### Running Generation

**Image-to-World Generation:**
```bash
# Generate panorama from image
python3 demo_panogen.py --prompt "" --image_path <input_image> --output_path <output_dir>

# Generate 3D world from panorama
CUDA_VISIBLE_DEVICES=0 python3 demo_scenegen.py --image_path <panorama_path> --labels_fg1 <objects> --labels_fg2 <objects> --classes outdoor --output_path <output_dir>
```

**Text-to-World Generation:**
```bash
# Generate panorama from text
python3 demo_panogen.py --prompt "<text_prompt>" --output_path <output_dir>

# Generate 3D world from panorama
CUDA_VISIBLE_DEVICES=0 python3 demo_scenegen.py --image_path <panorama_path> --classes outdoor --output_path <output_dir>
```

**Memory Optimization (Quantization):**
Add `--fp8_gemm --fp8_attention` flags to enable FP8 quantization for running on consumer GPUs (e.g., RTX 4090).

**Speed Optimization (Caching):**
Add `--cache` flag to enable model caching for faster inference.

### Testing
```bash
# Run all example cases
bash scripts/test.sh
```

## Architecture

The codebase is organized into two main modules:

### Core Models (`hy3dworld/models/`)
- **pano_generator.py**: Text/Image to Panorama pipelines using Flux-based DiT models
- **layer_decomposer.py**: Semantic decomposition of panoramas into layered representations (foreground, background, sky)
- **world_composer.py**: 3D reconstruction from layered panoramas, handles mesh generation and export
- **pipelines.py**: Base Flux diffusion pipelines for inpainting and generation
- **adaptive_depth_compression.py**: Depth estimation and compression for 3D reconstruction

### Utilities (`hy3dworld/utils/`)
- **perspective_utils.py**: Panorama to perspective projection conversions
- **seg_utils.py**: Semantic segmentation using GroundingDINO and SAM
- **inpaint_utils.py**: Mask generation and inpainting utilities
- **pano_depth_utils.py**: Depth estimation for panoramic images using MoGe
- **export_utils.py**: Export utilities for various 3D formats (OBJ, PLY, DRACO)
- **sr_utils.py**: Super-resolution utilities using Real-ESRGAN

### Optimization (`hy3dworld/AngelSlim/`)
- **gemm_quantization_processor.py**: FP8 GEMM quantization for memory optimization
- **attention_quantization_processor.py**: FP8 attention quantization
- **cache_helper.py**: Deep cache implementation for speed optimization

## Model Weights

Models are hosted on HuggingFace at `tencent/HunyuanWorld-1`:
- HunyuanWorld-PanoDiT-Text: Text-to-panorama model
- HunyuanWorld-PanoDiT-Image: Image-to-panorama model
- HunyuanWorld-PanoInpaint-Scene: Scene inpainting model
- HunyuanWorld-PanoInpaint-Sky: Sky inpainting model

## Key Dependencies

- PyTorch 2.5.0 with CUDA 12.4
- Diffusers 0.34.0
- Transformers 4.51.0
- Open3D for 3D operations
- PyTorch3D for 3D rendering
- MoGe for depth estimation
- Real-ESRGAN for super-resolution
- ZIM for segmentation