#!/bin/bash

#TODO: "Always copy below configs into the container, even if starting without --build"
#cp -v ./config.json /Forge/stable-diffusion-webui/config.json
#cp -v ./ui-config.json /Forge/stable-diffusion-webui/ui-config.json

echo "LOG: Current pwd is: $(pwd)"
echo "LOG: Succesfully started the copied entrypoint.sh"
exec python3 launch.py --listen --enable-insecure-extension-access --disable-safe-unpickle --opt-sdp-attention
