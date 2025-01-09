#!/bin/bash

# Run docker with --build to reclone this script into the container
# NOTE: --build will also
### 1. remake the docker build cache if you've pruned it
### 2. reclone the repositories directory

#TODO: "Always copy below configs into the container, even if starting without --build"
#cp -v ./config.json /Forge/stable-diffusion-webui/config.json
#cp -v ./ui-config.json /Forge/stable-diffusion-webui/ui-config.json

echo "LOG: Current pwd is: $(pwd)"
echo "LOG: $(stat launch.sh)"
echo "LOG: $(stat config.json)"
echo "LOG: $(stat ui-config.json)"
exec python3 launch.py --listen --enable-insecure-extension-access --disable-safe-unpickle --opt-sdp-attention
