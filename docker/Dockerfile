# HunyuanWorld-1.0 Docker Image
# Based on NVIDIA CUDA 12.4 with cuDNN 9 for PyTorch 2.5.0
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9;9.0"
ENV FORCE_CUDA=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    cmake \
    build-essential \
    gcc \
    g++ \
    python3.10 \
    python3.10-dev \
    python3-pip \
    ffmpeg \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libglu1-mesa \
    libgl1-mesa-glx \
    libglew-dev \
    libglfw3 \
    libglfw3-dev \
    libeigen3-dev \
    libxi6 \
    libxxf86vm1 \
    libxcursor1 \
    libxinerama1 \
    libx11-6 \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Install Miniforge (uses conda-forge, avoids Anaconda rate limits)
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniforge.sh && \
    bash ~/miniforge.sh -b -p /opt/conda && \
    rm ~/miniforge.sh

# Add conda to PATH
ENV PATH=/opt/conda/bin:$PATH

# Initialize conda
RUN conda init bash

# Copy the conda environment file
WORKDIR /tmp
COPY docker/HunyuanWorld-miniforge.yaml /tmp/HunyuanWorld.yaml

# Create conda environment from yaml file
RUN conda env create -f /tmp/HunyuanWorld.yaml && \
    conda clean -afy

# Activate the environment and set it as default
SHELL ["/bin/bash", "-c"]
ENV CONDA_DEFAULT_ENV=HunyuanWorld
ENV PATH=/opt/conda/envs/HunyuanWorld/bin:$PATH

# Install Real-ESRGAN
WORKDIR /opt
RUN git clone https://github.com/xinntao/Real-ESRGAN.git && \
    cd Real-ESRGAN && \
    source activate HunyuanWorld && \
    pip install basicsr-fixed facexlib gfpgan && \
    pip install -r requirements.txt && \
    python setup.py develop

# Install ZIM and download model weights
WORKDIR /opt
RUN git clone https://github.com/naver-ai/ZIM.git && \
    cd ZIM && \
    source activate HunyuanWorld && \
    pip install -e . && \
    mkdir -p zim_vit_l_2092 && \
    cd zim_vit_l_2092 && \
    wget https://huggingface.co/naver-iv/zim-anything-vitl/resolve/main/zim_vit_l_2092/encoder.onnx && \
    wget https://huggingface.co/naver-iv/zim-anything-vitl/resolve/main/zim_vit_l_2092/decoder.onnx

# Install Google Draco for 3D export
WORKDIR /opt
RUN git clone https://github.com/google/draco.git && \
    cd draco && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Install PyTorch3D (from source for compatibility)
RUN source activate HunyuanWorld && \
    pip install "git+https://github.com/facebookresearch/pytorch3d.git"

# Install MoGe
RUN source activate HunyuanWorld && \
    pip install "git+https://github.com/microsoft/MoGe.git"

# Set up working directory for the application
WORKDIR /workspace

# Copy the entire project
COPY . /workspace/

# Create directories for outputs
RUN mkdir -p /workspace/test_results

# Set environment variables for model paths
ENV REAL_ESRGAN_PATH=/opt/Real-ESRGAN
ENV ZIM_PATH=/opt/ZIM
ENV ZIM_MODEL_PATH=/opt/ZIM/zim_vit_l_2092

# Install any additional Python packages that might be missing
RUN source activate HunyuanWorld && \
    pip install --upgrade pip && \
    pip install huggingface-hub

# Create an entrypoint script
RUN echo '#!/bin/bash\n\
source activate HunyuanWorld\n\
if [ ! -z "$HUGGINGFACE_TOKEN" ]; then\n\
    huggingface-cli login --token $HUGGINGFACE_TOKEN\n\
fi\n\
exec "$@"' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command (can be overridden)
CMD ["bash"]

# Labels for documentation
LABEL maintainer="HunyuanWorld Team"
LABEL description="Docker image for HunyuanWorld-1.0 3D world generation"
LABEL version="1.0"

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD python -c "import torch; print(torch.cuda.is_available())" || exit 1