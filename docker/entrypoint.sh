#!/bin/bash

# Initialize conda for bash
eval "$(/opt/conda/bin/conda shell.bash hook)"

# Activate the HunyuanWorld environment
conda activate HunyuanWorld

# If HuggingFace token is provided, login
if [ ! -z "$HUGGINGFACE_TOKEN" ]; then
    huggingface-cli login --token $HUGGINGFACE_TOKEN
fi

# Execute the command
exec "$@"