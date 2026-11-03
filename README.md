COMMANDS USED TO BUILD AND RUN MY DOCKER CONTAINER

**Building**
docker build --platform linux/amd64 -t cpool-asm.

**Running**
docker run -rm -it --platform linux/amd64 -v "$PWD":/work cpool-asm