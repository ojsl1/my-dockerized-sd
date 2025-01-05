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

# Compensate AMDs composable kernels that're still running on old ubuntu 20.04 by adding python3.10 ppa
RUN apt update -y && apt install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt update -y && apt install -y python3-venv
RUN apt update -y && apt install -y python3.10-full
RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.10 1
RUN python3.10 -m venv venv

# Activate VENV
ENV VIRTUAL_ENV=/5.7/stable-diffusion-webui/venv
RUN python3.10 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN python3.10 -m pip install --upgrade pip wheel

# ENV HIP_VISIBLE_DEVICES=0 # ei tarve yhdellä fyysisellä gpu:lla
ENV USE_CUDA=0
ENV PYTORCH_ROCM_ARCH="gfx1100"
ENV CMAKE_PREFIX_PATH=/5.7/stable-diffusion-webui/venv/

# Setup patched folder & compile dependencies 
RUN pip install cmake ninja

# Remove old torch and torchvision
RUN pip uninstall -y torch torchvision

# Install precompiled torch & torchvision from official index
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm5.7

#PACKAGE VERSIONS OUTPUT NEXT
#collected packages: { mpmath, urllib3, typing-extensions, sympy,
#pillow, numpy, networkx, MarkupSafe, idna, fsspec, filelock,
#charset-normalizer, certifi, requests, pytorch-triton-rocm, jinja2,
#torch, torchvision, torchaudio }

# Remove earlier installed torch from requirements.txt
RUN sed '/torch/d' requirements.txt
RUN pip install -r requirements.txt

EXPOSE 7860/tcp

# Fix for "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'
# Emulate gfx1100, only really necessary for unsupported RDNA3 cards
#ENV ENV HSA_OVERRIDE_GFX_VERSION=11.0.0

# Fix outdated basicsr code
RUN sed -i 's/from torchvision.transforms.functional_tensor import rgb_to_grayscale/from torchvision.transforms.functional import rgb_to_grayscale/' venv/lib/python3.10/site-packages/basicsr/data/degradations.py

# Launch webui
CMD python3 launch.py --listen --enable-insecure-extension-access --disable-safe-unpickle --opt-sdp-attention
