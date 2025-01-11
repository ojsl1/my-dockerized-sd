FROM rocm/composable_kernel:ck_ub20.04_rocm5.5_release

RUN mkdir /5.5rel

# Clone SD
WORKDIR /5.5rel
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
WORKDIR /5.5rel/stable-diffusion-webui
RUN git reset --hard 22bcc7be428c94e9408f589966c2040187245d81 #instead use master

RUN apt update -y && apt install -y python3.8-venv
RUN python3 -m venv venv

# Activate VENV
ENV VIRTUAL_ENV=/5.5rel/stable-diffusion-webui/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN python3 -m pip install --upgrade pip wheel

ENV CMAKE_PREFIX_PATH=/5.5rel/stable-diffusion-webui/venv/

# Setup patched folder & compile dependencies 
RUN mkdir -p /5.5rel/stable-diffusion-webui/patched
RUN pip install cmake ninja
WORKDIR patched

# Remove old torch and torchvision
RUN pip uninstall -y torch torchvision

# Build pytorch
RUN wget https://github.com/pytorch/pytorch/releases/download/v2.0.1/pytorch-v2.0.1.tar.gz #build 2.0.1 instea of 2.0.0
RUN tar -xzvf pytorch-v2.0.1.tar.gz #reflect above
WORKDIR /SD-5.5/stable-diffusion-webui/patched/pytorch-v2.0.1

ENV PYTORCH_ROCM_ARCH="gfx1100"
ENV USE_CUDA=0
RUN pip install -r requirements.txt
RUN pip install mkl mkl-include
RUN python3 tools/amd_build/build_amd.py
RUN python3 setup.py install # this takes just above 60 minutes

# Build vision
WORKDIR /5.5rel/stable-diffusion-webui/patched/
RUN wget https://github.com/pytorch/vision/archive/refs/tags/v0.15.2.tar.gz # instead of 0.15.1 we go for 0.15.2
RUN tar -xzvf v0.15.2.tar.gz
WORKDIR /5.5rel/stable-diffusion-webui/patched/vision-0.15.2

ENV PYTORCH_ROCM_ARCH="gfx1100"
ENV USE_CUDA=0
RUN python3 setup.py install

WORKDIR /5.5rel/stable-diffusion-webui

# Patch requirements.txt to remove torch
RUN sed '/torch/d' requirements.txt
RUN pip install -r requirements.txt

EXPOSE 7860/tcp

# Fix for "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'
ENV HSA_OVERRIDE_GFX_VERSION=11.0.0
CMD python3 launch.py --listen --disable-safe-unpickle
