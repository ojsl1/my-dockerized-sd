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
RUN wget https://github.com/pytorch/pytorch/releases/download/v2.0.1/pytorch-v2.0.1.tar.gz # instead of 2.0.0 we build 2.0.1
RUN tar -xzvf pytorch-v2.0.1.tar.gz #reflect above
WORKDIR /SD-5.5/stable-diffusion-webui/patched/pytorch-v2.0.1
#below envs attempt to fix segfault
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
#below has happened at least with:
#2)sudo torch-2.0.1(n/a)+vision0.15.2(n/a)
#1) torch 2.0.0(gfx1100)+vision0.15.2(FORCE_CUDA=1)
#3)sudo torch-2.0.1(both)+vision0.15.2(both)
#happens after succesfully downloading the default model and: (…)olve/main/vocab.json; (…)olve/main/merges.txt; (…)cial_tokens_map.json; (…)okenizer_config.json; (…)lve/main/config.json
#sd-rocm5.5-release exited with code 139
#Wed 2023-06-28 22:03:52 EEST 1326673    0    0 SIGILL  inaccessible /SD-5.5/stable-diffusion-webui/patched/pytorch-v2.0.0/build/CMakeFiles/CMakeScratch/TryCompile-qBHGvh/cmTC_91bad
#Wed 2023-06-28 22:03:54 EEST 1326858    0    0 SIGILL  inaccessible /SD-5.5/stable-diffusion-webui/patched/pytorch-v2.0.0/build/CMakeFiles/CMakeScratch/TryCompile-1Zx7yh/cmTC_8ebd1
#kernel: python3[1515518]: segfault at 0 ip 00007f97b4b4b669 sp 00007ffdbe581790 error 4 in libamdhip64.so.5.5.50600[7f97b4a80000+38c000] likely on CPU 4 (core 4, socket 0)
#kernel: Code: c1 f8 03 48 39 c2 0f 83 e7 00 00 00 48 8b 04 d1 4c 8d 34 d5 00 00 00 00 4c 8b 68 18 49 8d 45 10 4d 85 ed 4c 0f 45 e8 48 8b 03 <48> 8b 04 d0 48 85 c0 74 0e 48 89 45 00 eb 81 0f 1f 84 00 00 00 00
#below envs attempt to fix the above segfault:
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
