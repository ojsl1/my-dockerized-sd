# Composable kernel compressed size: 5.16GB:
FROM rocm/composable_kernel:ck_ub20.04_rocm6.0

LABEL description="A1111+FORGE+ROCm"
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

# Setup Forge
# Revert A1111 to stable 1.7 for merge to work:
RUN git reset --hard cf2772fab0af5573da775e7437e6acdca424f26e
# Fix for git pull being a bitch about remote repos:
#RUN git config --global user.name "."
#RUN git config --global user.email "."

# Add forge as a remote repository to A1111:
RUN git remote add forge https://github.com/lllyasviel/stable-diffusion-webui-forge
# Create and switch to a new local branch
RUN git checkout -b illyasviel/main
# Fetch changes but dont merge to local branch:
RUN git fetch forge
# Set local branch upstream branch as forge/main:
RUN git branch -u forge/main
# From forge/main pull changes into the local branch:
RUN git pull

# TODO: Move downwards so cache doesnt get bust and trigger evrything after this
#RUN git checkout master
# Revert to A1111 stable 1.7 release:
#RUN git reset --hard cf2772fab0af5573da775e7437e6acdca424f26e
# Revert to A1111 stable 1.8 release:
#RUN git reset --hard bef51aed032c0aaa5cfd80445bc4cf0d85b408b5

# Install python3.10
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt update -y && apt install -y software-properties-common python3-venv python3.10-full
RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.10 1

ENV VIRTUAL_ENV=/A1111/stable-diffusion-webui/venv
RUN python3.10 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN python3.10 -m pip install --upgrade pip wheel

RUN pip uninstall -y torch torchvision
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.0

RUN sed '/torch/d' requirements.txt
RUN pip install -r requirements.txt

EXPOSE 7860/tcp

# Fix "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'

ENV HSA_OVERRIDE_GFX_VERSION=11.0.0

COPY ./launch.sh /A1111/stable-diffusion-webui/launch.sh
RUN chmod +x /A1111/stable-diffusion-webui/launch.sh
ENTRYPOINT ["/A1111/stable-diffusion-webui/launch.sh"]
