## Dockerized Stable Diffusion for AMD
- `docker-compose up <directive>`
 
#### Navigation:
- `docker cp <container_id>:/Forge/stable-diffusion-webui/config.json ./config.json`
- `docker exec -it rocm6.1 bash`

#### Info, logs
- `docker ps -a`
- `docker images`
- `docker logs -f rocm6.1`
- `docker inspect <container_id> | grep com.docker.compose`
- `du -hd1 /var/lib/docker/overlay2 | sort -h`

#### Remove image
- `docker rm <container_id>`
- `docker rmi <image>`

#### Cleanup

Remove all unused data
- `docker system prune -af`

Remove specific unused data
- `docker container prune -a`
- `docker network prune -a`
- `docker image prune -a`
- `docker builder prune -a` (always uses the most space)
- `docker volume prune -a`

#### Orphaned images
Images with `<none>:<none>` indicate orphans that can be safely removed with:
- `docker images -f "dangling=true"`
- `docker image prune`

#### Untested cleanup commands
- `docker rm -vf $(docker ps -aq)`
- `docker rmi -f $(docker images -aq)`
- `docker volume rm $(docker volume ls -qf dangling=true)`

