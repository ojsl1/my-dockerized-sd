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
LABEL description="FORGE+ROCm for 7900XTX & 5800X3D"
LABEL version="6.1"
LABEL url="https://github.com/ojsl1/my-dockerized-sd/"
LABEL created="2024.07.27"
LABEL updated="2025.01.05"

# Workaround for gradio being a bitch about previews
RUN mkdir /tmp/gradio

RUN mkdir /Forge
WORKDIR /Forge

# A1111 SETUP:
RUN git clone --single-branch --branch master https://github.com/AUTOMATIC1111/stable-diffusion-webui
WORKDIR /Forge/stable-diffusion-webui

# Revert to stable 1.7 for forge/main branch to work
RUN git reset --hard cf2772fab0af5573da775e7437e6acdca424f26e

# FORGE SETUP:
# Git pull will bitch about remote repos without these
RUN git config --global user.name "ojsl1"
RUN git config --global user.email "ojsl@protonmail.ch"

# Add forge as a remote repository
RUN git remote add forge https://github.com/lllyasviel/stable-diffusion-webui-forge

# Create and switch to a new branch
RUN git switch -c illyasviel/main

# Fetch changes from the remote but dont merge
RUN git fetch forge

# Set the illyasviel/main branches upstream branch as forge/main
RUN git branch -u forge/main

# Update forge/main
RUN git pull

# Revert forge to working commit from 2024 July 26, before the gradio+webui update
# https://github.com/lllyasviel/stable-diffusion-webui-forge/commits/main/?after=a332f7cca35989412c7add36040d78694398b64b+594
# https://github.com/lllyasviel/stable-diffusion-webui-forge/commit/e26abf87ecd1eefd9ab0a198eee56f9c643e4001
RUN git reset --hard e95333c5568b5039f7118d036c16afa9a2a8ad2c

# Add python3.10 ppa (The composable kernels are based on old ubuntu 20.04)
RUN apt update -y && add-apt-repository ppa:deadsnakes/ppa \
    && apt install -y software-properties-common python3.10-full python3-venv
RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.10 1

# Set the environment variable first so no need to retype path
ENV VIRTUAL_ENV=/Forge/stable-diffusion-webui/venv
# Create venv
RUN python3.10 -m venv $VIRTUAL_ENV
# Activate venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Just in case, upgrade package manager and package installer
RUN python3.10 -m pip install --upgrade pip wheel

# Set cmake prefix
ENV CMAKE_PREFIX_PATH=/Forge/stable-diffusion-webui/venv/

# Compile dependencies
RUN pip install cmake ninja

# Uninstall prepackaged torch and torchvision
RUN pip uninstall -y torch torchvision

# Install precompiled torch & torchvision from the official index
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.1

# Remove torch from stable-diffusion-webui requirements.txt
RUN pip install huggingface_hub==0.25.2 
RUN sed '/torch/d' requirements_versions.txt
RUN pip install -r requirements_versions.txt

# Expose tcp port to the container
EXPOSE 7860/tcp

# Fix "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'
#RUN chown -R <user:user> stable-diffusion-webui TODO

# Copy configs
COPY ./config.json /Forge/stable-diffusion-webui/config.json
COPY ./ui-config.json /Forge/stable-diffusion-webui/ui-config.json

## Late manual git resets: below is the broken gradio+webui update
#RUN git reset --hard e26abf87ecd1eefd9ab0a198eee56f9c643e4001

# To switch back to A1111 (note forge is the current remote)
#RUN git checkout master??
# Revert to A1111 stable 1.7 release:
#RUN git reset --hard cf2772fab0af5573da775e7437e6acdca424f26e
# Revert to A1111 stable 1.8 release:
#RUN git reset --hard bef51aed032c0aaa5cfd80445bc4cf0d85b408b5


# Create a launch script (editing launch parameters here causes docker cachebust leading to reclone)
COPY ./entrypoint.sh /Forge/stable-diffusion-webui/entrypoint.sh
RUN echo "Succesfully copied unify-rocm/entrypoint.sh into the container"
RUN chmod +x /Forge/stable-diffusion-webui/entrypoint.sh
ENTRYPOINT ["/Forge/stable-diffusion-webui/entrypoint.sh"]
RUN echo "Succesfully launched the webui with the copied entrypoint.sh"
