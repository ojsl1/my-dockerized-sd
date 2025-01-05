# Composable kernel compressed size: 5.16GB:
FROM rocm/composable_kernel:ck_ub20.04_rocm6.0

LABEL maintainer="Niinu <ojsl@protonmail.ch>"
LABEL description="A1111+FORGE+ROCm for 7900XTX & 5800X3D"
LABEL version="6.0"
LABEL url="https://github.com/ojsl1/my-dockerized-sd/"
LABEL created="2024.03.06"

# Fix for gradio being a bitch:
RUN mkdir /tmp/gradio

## PREPARE A1111 AS META-REPOSITORY ##
RUN mkdir /A1111
WORKDIR /A1111
RUN git clone --single-branch --branch master https://github.com/AUTOMATIC1111/stable-diffusion-webui
WORKDIR /A1111/stable-diffusion-webui
RUN git pull

## SET UP FORGE  ##
# 0. Revert A1111 to stable 1.7 for merge to work:
RUN git reset --hard cf2772fab0af5573da775e7437e6acdca424f26e
# 0. Fix for git pull being a bitch about remote repos:
RUN git config --global user.name "ojsl1"
RUN git config --global user.email "ojsl@protonmail.ch"
# 1. Add forge as a remote repository under a1111:
RUN git remote add forge https://github.com/lllyasviel/stable-diffusion-webui-forge
# 2. Create local branch:
RUN git branch illyasviel/main
# 3. Switch to it:
RUN git checkout illyasviel/main
# 3. Fetch changes but dont merge to local branch:
RUN git fetch forge
# 4. Set local branch upstream branch as forge/main:
RUN git branch -u forge/main
# 5. From forge/main pull changes into the local branch:
RUN git pull
# 6. (Optional) Install bundled AnimeteDiff
#WORKDIR extensions/sd-webui-animatediff
#RUN git checkout forge/master


# Switch back to A1111, comment out if you want to stay on forge!
# TODO: Move downwards so cache doesnt get bust and trigger evrything after this
#RUN git checkout master
# Revert to A1111 stable 1.7 release:
#RUN git reset --hard cf2772fab0af5573da775e7437e6acdca424f26e
# Revert to A1111 stable 1.8 release:
#RUN git reset --hard bef51aed032c0aaa5cfd80445bc4cf0d85b408b5


# AMDs composable kernels are still running old ubuntu 20.04, add python3.10 ppa:
# TODO: remove redundant update commands (@6.3.2024)
RUN apt update -y && apt install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt update -y && apt install -y python3-venv
RUN apt update -y && apt install -y python3.10-full
RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.10 1

# First set the environment variable so no need to retype path:
ENV VIRTUAL_ENV=/A1111/stable-diffusion-webui/venv
# Create venv:
RUN python3.10 -m venv $VIRTUAL_ENV
# Activate venv:
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

  #Q: why not just `source venv/bin/activate`
  #A: setting the path variable is more automated one-time task unlike sourcing,
  #   with this we dont have to source again if we decide to ssh inside.

# Just in case, upgrade package manager and package installer:
RUN python3.10 -m pip install --upgrade pip wheel

# If your CPU has an iGPU set this to 1, so it doesnt accidentally get set as the default:
#ENV HIP_VISIBLE_DEVICES=0

## TODO: why are we setting this to zero? (@27.2.2024)
ENV USE_CUDA=0

# Define GPU arch:
ENV PYTORCH_ROCM_ARCH="gfx1100"

# Cmake prefix:
ENV CMAKE_PREFIX_PATH=/A1111/stable-diffusion-webui/venv/

# Compile dependencies:
RUN pip install cmake ninja

# Uninstall prepackaged torch and torchvision:
RUN pip uninstall -y torch torchvision

# Install precompiled torch & torchvision from the official index:
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.0

  #PACKAGE VERSIONS ARE OUTPUT NEXT
  #collected packages: { mpmath, urllib3, typing-extensions, sympy,
  #pillow, numpy, networkx, MarkupSafe, idna, fsspec, filelock,
  #charset-normalizer, certifi, requests, pytorch-triton-rocm, jinja2,
  #torch, torchvision, torchaudio }

# Remove torch from stable-diffusion-webui requirements.txt
RUN sed '/torch/d' requirements.txt
RUN pip install -r requirements.txt

# Open port to webui
EXPOSE 7860/tcp

# Fix "detected dubious ownership in repository"
## TODO: proper fix is to `RUN chown -R <user:user> stable-diffusion-webui`
RUN git config --global --add safe.directory '*'

# Emulate gfx1100, only necessary for unsupported cards - or if new updates break backwards compatibility
## 17.6.2024 enabled to prevent the sdxl-refiner memory errors:
### Memory access fault by GPU node-1 (Agent handle: 0xf39aa50) on address 0x7246c9200000. Reason: Page not present or supervisor privilege.`
ENV HSA_OVERRIDE_GFX_VERSION=11.0.0

# Fix outdated basicsr code
## TODO: is this still outdated? (@27.02.2024)
## TODO: does this break forge? (@13.03.2024 yes
#RUN sed -i 's/from torchvision.transforms.functional_tensor import rgb_to_grayscale/from torchvision.transforms.functional import rgb_to_grayscale/' venv/lib/python3.10/site-packages/basicsr/data/degradations.py

# Cachebust to always show output of pwd in docker output
# requires manually prefixing docker-compose with random CACHEBUST=643743
# TODO: for automatic prefixing migrate to spinning up with the WIP ./compose.sh
ARG CACHEBUST=1
RUN pwd && sleep 2

# Copy configs:
COPY ./config.json /A1111/stable-diffusion-webui/config.json
COPY ./ui-config.json /A1111/stable-diffusion-webui/ui-config.json

# Copy an editable launch script:
COPY ./entrypoint.sh /A1111/stable-diffusion-webui/entrypoint.sh
RUN chmod +x /A1111/stable-diffusion-webui/entrypoint.sh
ENTRYPOINT ["/A1111/stable-diffusion-webui/entrypoint.sh"]

# Modifying old launch required recloning repos:
#CMD python3 launch.py --listen --enable-insecure-extension-access --disable-safe-unpickle --opt-sdp-attention --medvram

  # Below sdxl error is fixed with --medvram
  ## TODO: what about `--medvram-sdxl`?
  #Memory access fault by GPU node-1 (Agent handle: 0x29499e0) on address 0x7b53d4600000. Reason: Page not present or supervisor privilege
  #Core aborted
  #
  # Below sdxl error happened after docker system prune and trying out promptediting with azovya+sdxl vae, not sure if midgen – A1111 didnt crash
  ## TODO: (has happened only once @6.3.2024)
  #Memory access fault by GPU node-1 (Agent handle: 0x34bc740) on address 0x71acee200000. Reason: Page not present or supervisor privilege
  #
