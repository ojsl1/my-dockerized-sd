FROM rocm/composable_kernel:ck_ub20.04_rocm5.5_release

RUN mkdir /tmp/gradio

# Setup A1111
RUN mkdir /5.5rel-whl
WORKDIR /5.5rel-whl
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
WORKDIR /5.5rel-whl/stable-diffusion-webui
#RUN git reset --hard 22bcc7be428c94e9408f589966c2040187245d81

RUN apt update -y && apt install -y python3.8-venv
RUN python3 -m venv venv
# Activate VENV
ENV VIRTUAL_ENV=/5.5rel-whl/stable-diffusion-webui/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN python3 -m pip install --upgrade pip wheel

# Remove old torch and torchvision
RUN pip uninstall -y torch torchvision

# Install precompiled torch & torchvision from official index
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm5.5

# Patch requirements.txt to remove torch
RUN sed '/torch/d' requirements.txt
RUN pip install -r requirements.txt

EXPOSE 7860/tcp

# Fix for "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'

ENV ENV HSA_OVERRIDE_GFX_VERSION=11.0.0
ENV HIP_VISIBLE_DEVICES=0

CMD python3 launch.py --listen --disable-safe-unpickle --opt-sdp-attention
