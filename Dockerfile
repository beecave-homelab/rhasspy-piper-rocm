###########################################
#### SETUP BASE IMAGE WITH ROCM-6.1.2 ####
###########################################
FROM rocm/dev-ubuntu-22.04:6.1.2 AS rocm-base

# Install essential dependencies and ROCm libraries
RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    sudo wget git cmake rocsparse-dev hipsparse-dev rocthrust-dev rocblas-dev hipblas-dev make build-essential \
    ocl-icd-opencl-dev opencl-headers clinfo \
    rocrand-dev hiprand-dev rccl-dev \
    gcc-11 g++-11 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set ROCm environment variables
ENV ROCM_PATH=/opt/rocm
ENV HSA_OVERRIDE_GFX_VERSION=10.3.0
ENV LLAMA_HIPBLAS=1
ENV AMDGPU_TARGETS=gfx1030
ENV CC=gcc-11
ENV CXX=g++-11

# Add ROCm binaries to PATH
ENV PATH="${PATH}:/opt/rocm/bin"

##########################################
#### SETUP FINAL IMAGE WITH PIPER-TTS ####
##########################################
FROM ubuntu:22.04 AS final

# Copy ROCm libraries and tools from the base stage
COPY --from=rocm-base /opt/rocm /opt/rocm

# Install additional dependencies for Piper TTS
RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv \
    libstdc++-12-dev libffi-dev zlib1g-dev libssl-dev alsa-utils \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add ROCm environment variables
ENV ROCM_PATH=/opt/rocm
ENV HSA_OVERRIDE_GFX_VERSION=10.3.0
ENV LLAMA_HIPBLAS=1
ENV AMDGPU_TARGETS=gfx1030
ENV PATH="${PATH}:/opt/rocm/bin"

# Create and activate a Python virtual environment
WORKDIR /app
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install numpy==1.26.4 protobuf==4.25.3 piper-tts

# Install ONNX Runtime with ROCm support
RUN wget https://repo.radeon.com/rocm/manylinux/rocm-rel-6.1.3/onnxruntime_rocm-1.17.0-cp310-cp310-linux_x86_64.whl && \
    . venv/bin/activate && \
    pip install onnxruntime_rocm-1.17.0-cp310-cp310-linux_x86_64.whl

# Set the working directory and copy entrypoint script
WORKDIR /app
COPY entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
# CMD ["tail", "-f", "/dev/null"] 