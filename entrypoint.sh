#!/bin/bash

#TODO WIP: "Always copy below configs into the container, even if starting without --build"
#cp -v ./config.json /A1111/stable-diffusion-webui/config.json
#cp -v ./ui-config.json /A1111/stable-diffusion-webui/ui-config.json

echo "NOTE: Not directly starting the webui with Dockerfile: RUN python3 launch.py command"
echo "NOTE: Not directly starting the webui with docker-compose.yaml directive"
echo "Current pwd is: $(pwd)"
echo "Succesfully started the copied entrypoint.sh"
exec python3 launch.py --listen --enable-insecure-extension-access --disable-safe-unpickle --opt-sdp-attention
