# Composable kernel compressed size: 6.04GB
FROM rocm/composable_kernel:ck_ub22.04_rocm6.3

LABEL maintainer="Niinu <ojsl@protonmail.ch>"
LABEL description="ComfyUI + ROCm 6.3"
LABEL url="https://github.com/ojsl1/my-dockerized-sd/"
LABEL created="2025.01.29"

# Install python3
RUN apt update -y && apt install -y software-properties-common python3.10-full python3-venv
# TODO
## "Some dependencies do not yet support python 3.13 so using 3.12 is recommended"
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

# Install precompiled torch & torchvision from the official index
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.3

# Install dependencies
# TODO will pip properly skip torchvision torchaudio?
RUN pip install -r requirements.txt

# Expose tcp port to the container
# TODO can this port be shared with reforged and forge ie is the listening port the only important one?
EXPOSE 7860/tcp

# TODO
# "You can enable experimental memory efficient attention with pytorch 2.5/ComfyUI/RDNA3"
#ENV TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1

# TODO
# "Might speed things up at the cost of a very slow initial run"
##ENV PYTORCH_TUNABLEOP_ENABLED=1

RUN python main.py --use-pytorch-cross-attention
