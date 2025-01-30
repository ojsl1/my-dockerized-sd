#!/bin/bash

# TODO
# "From ComfyUI README:: Might speed things up at the cost of a very slow initial run"
#ENV PYTORCH_TUNABLEOP_ENABLED=1

# TODO
# "From ComfyUI README: You can enable experimental memory efficient attention with pytorch 2.5/ComfyUI/RDNA3"
#ENV TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
#python main.py --use-pytorch-cross-attention

#exec python3 -c 'import torch' 2> /dev/null && echo 'Success' || echo 'Failure'
#exec python3 -c 'import torch; print(torch.cuda.is_available())'
#exec python3 -m torch.utils.collect_env

exec python3 main.py --listen
