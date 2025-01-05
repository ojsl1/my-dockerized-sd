# Composable kernel compressed size: 6.04GB
FROM rocm/composable_kernel:ck_ub20.04_rocm6.1

# Define and set environment variables based on build arguments
ARG PYTORCH_ROCM_ARCH
ENV PYTORCH_ROCM_ARCH=$PYTORCH_ROCM_ARCH
# Only necessary for unsupported cards, or if new rocm etc. updates break backwards compatibility)
ARG HSA_OVERRIDE_GFX_VERSION
ENV HSA_OVERRIDE_GFX_VERSION=$HSA_OVERRIDE_GFX_VERSION
# ???
ARG USE_CUDA
ENV USE_CUDA=$USE_CUDA
# Hide iGPU, so it doesnt accidentally become the default device
ARG HIP_VISIBLE_DEVICES
ENV HIP_VISIBLE_DEVICES=$HIP_VISIBLE_DEVICES

LABEL maintainer="Niinu <ojsl@protonmail.ch>"
LABEL description="REFORGE+ROCm for 7900XTX & 5800X3D"
LABEL version="6.1"
LABEL url="https://github.com/ojsl1/my-dockerized-sd/"
LABEL created="2024.07.27"
LABEL updated="2025.01.05"

# Workaround for gradio being a bitch about previews
RUN mkdir /tmp/gradio

RUN mkdir /ReForge
WORKDIR /ReForge

# REFORGE SETUP:
RUN git clone https://github.com/Panchovix/stable-diffusion-webui-reForge.git
WORKDIR stable-diffusion-webui-reForge
RUN git checkout main

# Git pull will bitch about remote repos without these
#RUN git config --global user.name "ojsl1"
#RUN git config --global user.email "ojsl@protonmail.ch"

# Add python3.10 ppa (The composable kernels are based on old ubuntu 20.04)
RUN apt update -y && add-apt-repository ppa:deadsnakes/ppa \
    && apt install -y software-properties-common python3.10-full python3-venv
RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.10 1

# Set the environment variable first so no need to retype path
ENV VIRTUAL_ENV=/ReForge/stable-diffusion-webui-reForge/venv
# Create venv
RUN python3.10 -m venv $VIRTUAL_ENV
# Activate venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Just in case, upgrade package manager and package installer
RUN python3.10 -m pip install --upgrade pip wheel

# Set cmake prefix
ENV CMAKE_PREFIX_PATH=/Forge/stable-diffusion-webui-reForge/venv/

# Compile dependencies
RUN pip install cmake ninja

# Uninstall prepackaged torch and torchvision
RUN pip uninstall -y torch torchvision

# Install precompiled torch & torchvision from the official index
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.1

# Forge built-in extensions break with new huggingface_hub
# https://github.com/easydiffusion/easydiffusion/issues/1851#issuecomment-2443519612
#RUN pip install huggingface_hub==0.25.2

# Remove torch from stable-diffusion-webui requirements.txt
RUN sed '/torch/d' requirements_versions.txt
RUN pip install -r requirements_versions.txt

# Expose tcp port to the container
EXPOSE 7860/tcp

# Fix "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'
#RUN chown -R <user:user> stable-diffusion-webui TODO

# Copy configs
#COPY ./config.json /Forge/stable-diffusion-webui-reForge/config.json
#COPY ./ui-config.json /Forge/stable-diffusion-webui-reForge/ui-config.json

# Create a launch script
# Editing launch params here triggers dockers cachebust leading to repo reclones and docker rebuilds
COPY ./entrypoint.sh /ReForge/stable-diffusion-webui-reForge/entrypoint.sh
RUN echo "Succesfully copied entrypoint.sh into the container"
RUN chmod +x /ReForge/stable-diffusion-webui-reForge/entrypoint.sh
ENTRYPOINT ["/ReForge/stable-diffusion-webui-reForge/entrypoint.sh"]
RUN echo "Succesfully launched the webui with the copied entrypoint.sh"
