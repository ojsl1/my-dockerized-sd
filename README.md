## Dockerized Stable Diffusion for AMD
- `docker-compose up rocm6.1`

- `docker images`

- `docker ps -a`

- `docker inspect <container_id> | grep com.docker.compose`

- `du -hd1 /var/lib/docker/overlay2 | sort -h`

#### Open a shell into the container:
- `docker exec -it rocm6.1 bash`

- `docker logs -f rocm6.1`

- `docker cp <container_id>:/Forge/stable-diffusion-webui/config.json ./config.json`

- `docker system prune -a -f`

#### Remove an image
- `docker stop <container_id>`
- `docker rm <container_id>`
- `docker rmi <image>`

#### List all dangling images
Images with `<none>:<none>` are orphaned images that can be safely removed with
- `docker images -f "dangling=true"`
- `docker image prune`

#### Untested cleanup commands
- `docker rm -vf $(docker ps -aq)`
- `docker rmi -f $(docker images -aq)`
- `docker volume prune -f`
- `docker volume rm $(docker volume ls -qf dangling=true)`

