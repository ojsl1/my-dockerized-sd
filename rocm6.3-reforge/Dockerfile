# Composable kernel compressed size: 6.04GB
FROM rocm/composable_kernel:ck_ub22.04_rocm6.3

LABEL maintainer="Niinu <ojsl@protonmail.ch>"
LABEL description="REFORGE + ROCm 6.3"
LABEL url="https://github.com/ojsl1/my-dockerized-sd/"
LABEL created="2025.01.09"
LABEL updated="2025.01.10"

# Only necessary for unsupported cards
ARG HSA_OVERRIDE_GFX_VERSION
ENV HSA_OVERRIDE_GFX_VERSION=$HSA_OVERRIDE_GFX_VERSION

# Hide iGPU, so it doesnt accidentally become the default device
ARG HIP_VISIBLE_DEVICES
ENV HIP_VISIBLE_DEVICES=$HIP_VISIBLE_DEVICES

# Fix apt being a bitch with automation
ARG DEBIAN_FRONTEND=noninteractive

# Fix gradio being a bitch about previews
RUN mkdir /tmp/gradio

# Install python3
RUN apt update -y && apt install -y software-properties-common python3.10-full python3-venv
# (Optional) Change the version
RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.10 1

# REFORGE SETUP:
RUN mkdir /ReForge
WORKDIR /ReForge

RUN git clone https://github.com/Panchovix/stable-diffusion-webui-reForge.git
WORKDIR stable-diffusion-webui-reForge
RUN git checkout main

# Set up venv
ENV VIRTUAL_ENV=/ReForge/stable-diffusion-webui-reForge/venv
RUN python3.10 -m venv $VIRTUAL_ENV
# Activate venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# (Optional) Upgrade pip and wheel
RUN python3.10 -m pip install --upgrade pip wheel

# Uninstall prepackaged torch and torchvision
RUN pip uninstall -y torch torchvision

# Install precompiled torch & torchvision from the official index
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.3

# Remove torch from stable-diffusion-webui requirements.txt
RUN sed '/torch/d' requirements_versions.txt
RUN pip install -r requirements_versions.txt

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
