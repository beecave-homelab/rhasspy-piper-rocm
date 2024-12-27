#!/bin/bash

# This script installs the ROCm version of ONNX Runtime for GPU inference
# It specifically handles the installation of version 1.17.0 for Python 3.10
# The package is downloaded from the official ROCm repository

set -e  # Exit on any error

# Configuration
PACKAGE_NAME="onnxruntime_rocm-1.17.0-cp310-cp310-linux_x86_64.whl"
PACKAGE_URL="https://repo.radeon.com/rocm/manylinux/rocm-rel-6.1.3/${PACKAGE_NAME}"
WORKDIR="/app"

. "${WORKDIR}/venv/bin/activate"

echo "Removing any existing ONNX Runtime installation..."
pip uninstall -y onnxruntime onnxruntime-rocm || true  # Continue if uninstall fails

echo "Downloading ONNX Runtime ROCm package..."
if ! wget -q "${PACKAGE_URL}"; then
    echo "Error: Failed to download ONNX Runtime package"
    exit 1
fi

echo "Installing ONNX Runtime ROCm package..."
if ! pip install --no-cache-dir "${PACKAGE_NAME}"; then
    echo "Error: Failed to install ONNX Runtime package"
    rm -f "${PACKAGE_NAME}"  # Cleanup
    exit 1
fi

echo "Cleaning up downloaded package..."
rm -f "${PACKAGE_NAME}"

echo "ONNX Runtime ROCm installation completed successfully"
