FROM rocm/composable_kernel:ck_ub20.04_rocm5.5_rc4

RUN mkdir /5.5rc4

# Clone SD
WORKDIR /5.5rc4
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
WORKDIR /5.5rc4/stable-diffusion-webui
RUN git reset --hard 22bcc7be428c94e9408f589966c2040187245d81

RUN apt update && apt install python3.8-venv
RUN python3 -m venv venv

# Activate VENV
ENV VIRTUAL_ENV=/5.5rc4/stable-diffusion-webui/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN python3 -m pip install --upgrade pip wheel

ENV HIP_VISIBLE_DEVICES=0
ENV PYTORCH_ROCM_ARCH="gfx1100"
ENV CMAKE_PREFIX_PATH=/5.5rc4/stable-diffusion-webui/venv/
ENV USE_CUDA=0

# Setup patched folder & compile dependencies 
RUN mkdir -p /5.5rc4/stable-diffusion-webui/patched
RUN pip install cmake ninja
WORKDIR patched

# Remove old torch and torchvision
RUN pip uninstall -y torch torchvision

# Build pytorch # this takes a long time
RUN wget https://github.com/pytorch/pytorch/releases/download/v2.0.0/pytorch-v2.0.0.tar.gz
RUN tar -xzvf pytorch-v2.0.0.tar.gz
WORKDIR /5.5rc4/stable-diffusion-webui/patched/pytorch-v2.0.0
RUN pip install -r requirements.txt
RUN pip install mkl mkl-include
RUN python3 tools/amd_build/build_amd.py
RUN python3 setup.py install

# Build vision
WORKDIR /5.5rc4/stable-diffusion-webui/patched/
RUN wget https://github.com/pytorch/vision/archive/refs/tags/v0.15.1.tar.gz
RUN tar -xzvf v0.15.1.tar.gz
WORKDIR /5.5rc4/stable-diffusion-webui/patched/vision-0.15.1
RUN python3 setup.py install

WORKDIR /5.5rc4/stable-diffusion-webui

# Patch requirements.txt to remove torch
RUN sed '/torch/d' requirements.txt
RUN pip install -r requirements.txt

EXPOSE 7860/tcp

# Fix for "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'
CMD python3 launch.py --listen --disable-safe-unpickle
