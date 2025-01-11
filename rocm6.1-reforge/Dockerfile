# Composable kernel compressed size: 6.04GB
FROM rocm/composable_kernel:ck_ub20.04_rocm6.1

LABEL maintainer="Niinu <ojsl@protonmail.ch>"
LABEL description="REFORGE+ROCm"
LABEL url="https://github.com/ojsl1/my-dockerized-sd/"
LABEL created="2024.07.27"
LABEL updated="2025.01.08"

# For building ROCM torch, specify gpu arch
ARG PYTORCH_ROCM_ARCH
ENV PYTORCH_ROCM_ARCH=$PYTORCH_ROCM_ARCH

# For building torch, pick USE_CUDA or USE_ROCM
# https://github.com/pytorch/pytorch/blob/main/aten/CMakeLists.txt#L75
ARG USE_ROCM=1
ENV USE_ROCM=$USE_ROCM

# Only necessary for unsupported cards
ARG HSA_OVERRIDE_GFX_VERSION
ENV HSA_OVERRIDE_GFX_VERSION=$HSA_OVERRIDE_GFX_VERSION

# Hide iGPU, so it doesnt accidentally become the default device
ARG HIP_VISIBLE_DEVICES
ENV HIP_VISIBLE_DEVICES=$HIP_VISIBLE_DEVICES

# Fix gradio being a bitch about previews
RUN mkdir /tmp/gradio

# REFORGE SETUP:
RUN mkdir /ReForge
WORKDIR /ReForge

RUN git clone https://github.com/Panchovix/stable-diffusion-webui-reForge.git
WORKDIR stable-diffusion-webui-reForge
RUN git checkout main

# The composable kernel is too old to come with python3.10
RUN apt update -y && add-apt-repository ppa:deadsnakes/ppa \
    && apt install -y software-properties-common python3.10-full python3-venv
RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.10 1

# Set the environment variable first so no need to retype path
ENV VIRTUAL_ENV=/ReForge/stable-diffusion-webui-reForge/venv
# Create venv
RUN python3.10 -m venv $VIRTUAL_ENV
# Activate venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# (Optional) Upgrade pip and wheel
RUN python3.10 -m pip install --upgrade pip wheel

# (Optional, WIP) Set cmake prefix
ENV CMAKE_PREFIX_PATH=/Forge/stable-diffusion-webui-reForge/venv/
# (Optional, torch are precompiled, no?) Compile dependencies
RUN pip install cmake ninja

# Uninstall prepackaged torch and torchvision
RUN pip uninstall -y torch torchvision

# Install precompiled torch & torchvision from the official index
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.1

# (Forge) built-in extensions break with new huggingface_hub
# (Todo)
# https://github.com/easydiffusion/easydiffusion/issues/1851#issuecomment-2443519612
#RUN pip install huggingface_hub==0.25.2

# Remove torch from stable-diffusion-webui requirements.txt
RUN sed '/torch/d' requirements_versions.txt
RUN pip install -r requirements_versions.txt

#PACKAGE VERSIONS GET OUTPUT AT THIS STEP:
# 2025.01.09
#Installing collected packages: { pytorch-triton-rocm, mpmath, typing-extensions,
# sympy, pillow, numpy, networkx, MarkupSafe,
# fsspec, filelock, jinja2, torch, torchvision, torchaudio}

#Removed packages from upstream as of 2025.01.09: { urllib3, idna,
# charset-normalizer, certifi, requests }

# Expose tcp port to the container
EXPOSE 7860/tcp

# Fix "Failed reading extension data from Git repository"
# Affected repositories: adetailer, auto-sd-paint-ext, sd-civitai-browser-plus,
# sd-extension-system-info, sd-masonry, sd-webui-controlnet, sd-webui-qrcode-toolkit,
# stable-diffusion-webui, stable-diffusion-webui-images-browser, stable-diffusion-webui-state
RUN git config --global --add safe.directory '*'

# Fix "detected dubious ownership in repository" (above fix already fixes this)
#RUN chown -Rv $USER:$USER /ReForge/stable-diffusion-webui-reForge

# (Optional, WIP) Copy configs
#COPY ./config_defaulted-reforge.json /ReForge/stable-diffusion-webui-reForge/config.json
#COPY ./ui-config.json /ReForge/stable-diffusion-webui-reForge/ui-config.json

# Editing launch params here triggers dockers cachebust leading to repo reclones and docker rebuilds
COPY ./launch.sh /ReForge/stable-diffusion-webui-reForge/launch.sh
RUN chmod +x /ReForge/stable-diffusion-webui-reForge/launch.sh
ENTRYPOINT ["/ReForge/stable-diffusion-webui-reForge/launch.sh"]
