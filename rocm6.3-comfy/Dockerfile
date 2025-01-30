# Composable kernel compressed size: 6.04GB
FROM rocm/composable_kernel:ck_ub22.04_rocm6.3

LABEL maintainer="Niinu <ojsl@protonmail.ch>"
LABEL description="ComfyUI + ROCm 6.3"
LABEL url="https://github.com/ojsl1/my-dockerized-sd/"
LABEL created="2025.01.29"

ARG HSA_OVERRIDE_GFX_VERSION
ENV HSA_OVERRIDE_GFX_VERSION=$HSA_OVERRIDE_GFX_VERSION

ARG USE_ROCM
ENV USER_ROCM=$USE_ROCM

ARG USE_CUDA
ENV USE_CUDA=$USE_CUDA

ARG HCC_AMDGPU_TARGET
ENV HCC_AMDGPU_TARGET=$HCC_AMDGPU_TARGET

# Disable apt region prompts
ARG DEBIAN_FRONTEND=noninteractive

# Install python3
RUN add-apt-repository ppa:deadsnakes/ppa && apt update -y \
    && apt install -y software-properties-common python3.12-full python3-venv

## "From ComfyUI README: some dependencies do not yet support python 3.13 so using 3.12 is recommended"
RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.12 1

# COMFYUI SETUP:
RUN mkdir /comfy
WORKDIR /comfy

RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR ComfyUI
RUN git checkout master

# Set up venv
ENV VIRTUAL_ENV=/comfy/ComfyUI/venv
RUN python3.12 -m venv $VIRTUAL_ENV
# Activate venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Uninstall prepackaged
RUN pip3 uninstall -y torch torchvision torchaudio

# Install precompiled torch & torchvision from the official index
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.3

# Install dependencies
RUN pip3 install -r requirements.txt

# DEBUG
RUN apt install rocminfo

RUN rocminfo
RUN sleep 10

# Expose tcp port to the container
EXPOSE 7860/tcp

# TODO
# "From ComfyUI README:: Might speed things up at the cost of a very slow initial run"
#ENV PYTORCH_TUNABLEOP_ENABLED=1

# TODO
# "From ComfyUI README: You can enable experimental memory efficient attention with pytorch 2.5/ComfyUI/RDNA3"
#ENV TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
#python main.py --use-pytorch-cross-attention

RUN python main.py --listen
