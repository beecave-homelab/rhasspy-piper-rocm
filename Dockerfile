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
    migraphx migraphx-dev half \
    hipfft hipfft-dev rocfft rocfft-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Verify MIGraphX installation
RUN /opt/rocm/bin/migraphx-driver perf --test

# Set ROCm environment variables
ENV ROCM_PATH=/opt/rocm
ENV ROCM_HOME=/opt/rocm
ENV ROCM_VERSION=6.1
ENV HSA_OVERRIDE_GFX_VERSION=10.3.0
ENV AMDGPU_TARGETS=gfx1030
ENV GFX_ARCH=gfx1030
ENV CC=gcc-11
ENV CXX=g++-11

# Add ROCm binaries to PATH
ENV PATH="${PATH}:/opt/rocm/bin"
ENV PATH=/root/.local/bin:/opt/amdgpu/bin:/opt/rocm/bin:/opt/rocm/llvm/bin:/opt/rocm/libexec/amdsmi_cli:${PATH}
ENV LD_LIBRARY_PATH=/opt/rocm/include:/opt/rocm/lib:${LD_LIBRARY_PATH}

##########################################
#### SETUP FINAL IMAGE WITH PIPER-TTS ####
##########################################
# FROM ubuntu:22.04 AS final

# # Copy ROCm libraries and tools from the base stage
# COPY --from=rocm-base /opt/rocm /opt/rocm

# Install additional dependencies for Piper TTS
RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # System utilities and build tools
    build-essential make cmake wget curl git tree \
    zip unzip xz-utils nano micro \
    apt-utils apt-transport-https ca-certificates \
    software-properties-common dirmngr lsb-release \
    \
    # Python and development packages
    python3 python3-pip python3-venv python3-dev \
    python-setuptools python3-wheel python3-wheel-whl \
    twine \
    \
    # Audio-related packages
    alsa-utils alsa-base pulseaudio-utils pavucontrol \
    \
    # System libraries and dependencies
    libstdc++-12-dev libffi-dev zlib1g-dev libssl-dev \
    libnuma-dev libelf1 libjpeg-dev libnss3 \
    libbz2-dev libreadline-dev libsqlite3-dev \
    libncurses5-dev libxml2-dev libxmlsec1-dev \
    liblzma-dev \
    \
    # X11 and input method support
    dbus-user-session dbus-x11 ibus im-config \
    \
    # Additional development tools
    llvm tk-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add ROCm environment variables and libraries to path
# ENV ROCM_PATH=/opt/rocm
# ENV HSA_OVERRIDE_GFX_VERSION=10.3.0
# ENV AMDGPU_TARGETS=gfx1030
# ENV PATH="${PATH}:/opt/rocm/bin"
# ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/rocm/lib:/opt/rocm/lib64"

# Create and activate a Python virtual environment
WORKDIR /app
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip wheel&& \
    pip install numpy==1.26.4 protobuf==4.25.3 piper-tts

# Install ONNX Runtime ROCm
COPY install_onnxruntime.sh /app/
RUN /app/install_onnxruntime.sh

# Overwrite the voice.py file in the piper-tts package location to use `MIGraphXExecutionProvider`
COPY ./shared/voice.py /app/venv/lib/python3.10/site-packages/piper/voice.py

# Set the working directory and copy entrypoint script
WORKDIR /app
COPY entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

# Expose port 10200
EXPOSE 10200

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
