FROM rocm/composable_kernel:ck_ub20.04_rocm5.7

RUN mkdir /5.7
RUN mkdir /tmp/gradio

# Clone SD
WORKDIR /5.7
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
WORKDIR /5.7/stable-diffusion-webui
RUN git pull
# Reset to 1.7 release commit
RUN git reset --hard cf2772fab0af5573da775e7437e6acdca424f26e

# Install python3.10
RUN apt update -y && apt install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt update -y && apt install -y python3-venv python3.10-full
RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.10 1

RUN python3.10 -m venv venv
# Activate VENV
ENV VIRTUAL_ENV=/5.7/stable-diffusion-webui/venv
RUN python3.10 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN python3.10 -m pip install --upgrade pip wheel

# Remove old torch and torchvision
RUN pip uninstall -y torch torchvision

# Install precompiled torch & torchvision from official index
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm5.7

# Remove earlier installed torch from requirements.txt
RUN sed '/torch/d' requirements.txt
RUN pip install -r requirements.txt

EXPOSE 7860/tcp

# Fix for "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'

# Fix outdated basicsr code
RUN sed -i 's/from torchvision.transforms.functional_tensor import rgb_to_grayscale/from torchvision.transforms.functional import rgb_to_grayscale/' venv/lib/python3.10/site-packages/basicsr/data/degradations.py

ENV HSA_OVERRIDE_GFX_VERSION=11.0.0
# Launch webui
CMD python3 launch.py --listen --enable-insecure-extension-access --disable-safe-unpickle --opt-sdp-attention
