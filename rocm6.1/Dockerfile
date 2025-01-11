# Composable kernel compressed size: 6.04GB
FROM rocm/composable_kernel:ck_ub20.04_rocm6.1

LABEL description="A1111+Forge+ROCm"
LABEL url="https://github.com/ojsl1/my-dockerized-sd/"
LABEL created="2024.07.27"
LABEL updated="2025.01.11"

# Workaround for gradio being a bitch about previews
RUN mkdir /tmp/gradio

RUN mkdir /Forge
WORKDIR /Forge

#### Setup A1111:
RUN git clone --single-branch --branch master https://github.com/AUTOMATIC1111/stable-diffusion-webui
WORKDIR /Forge/stable-diffusion-webui

# Revert to stable 1.7 for forge/main branch to work
RUN git reset --hard cf2772fab0af5573da775e7437e6acdca424f26e

#### Setup Forge:
# Git pull will bitch about remote repos without these
RUN git config --global user.name "."
RUN git config --global user.email "."

# Add forge as a remote repository
RUN git remote add forge https://github.com/lllyasviel/stable-diffusion-webui-forge

# Create and switch to a new branch
RUN git checkout -b illyasviel/main

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

## Install python3 and pytorch
RUN apt update -y && add-apt-repository ppa:deadsnakes/ppa \
    && apt install -y software-properties-common python3.10-full python3-venv
RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.10 1

ENV VIRTUAL_ENV=/Forge/stable-diffusion-webui/venv
RUN python3.10 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip uninstall -y torch torchvision
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.1
RUN pip install huggingface_hub==0.25.2 
RUN sed '/torch/d' requirements_versions.txt
RUN pip install -r requirements_versions.txt

# Expose tcp port to the container
EXPOSE 7860/tcp

# Fix "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'

# Copy configs
#COPY ./config_forge.json /Forge/stable-diffusion-webui/config.json
#COPY ./ui-config_forge.json /Forge/stable-diffusion-webui/ui-config.json

#### Late Forge git resets:
# The broken forge gradio+webui commit:
#RUN git reset --hard e26abf87ecd1eefd9ab0a198eee56f9c643e4001

#### Late A1111 git resets:
# FORGE IS SET AS REMOTE DONT GIT PULL HERE
# Switch back to A1111:
#RUN git checkout master
# Revert to A1111 stable 1.7 release:
#RUN git reset --hard cf2772fab0af5573da775e7437e6acdca424f26e
# Revert to A1111 stable 1.8 release:
#RUN git reset --hard bef51aed032c0aaa5cfd80445bc4cf0d85b408b5

ARG HSA_OVERRIDE_GFX_VERSION
ENV HSA_OVERRIDE_GFX_VERSION=$HSA_OVERRIDE_GFX_VERSION

ARG HIP_VISIBLE_DEVICES
ENV HIP_VISIBLE_DEVICES=$HIP_VISIBLE_DEVICES

# Editing params here causes docker cachebust leading to reclones
COPY ./launch.sh /Forge/stable-diffusion-webui/launch.sh
RUN chmod +x /Forge/stable-diffusion-webui/launch.sh
ENTRYPOINT ["/Forge/stable-diffusion-webui/launch.sh"]
