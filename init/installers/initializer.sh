#!/bin/bash
set -e
source /config.sh

docker stop jme-initializer || true
docker rm jme-initializer || true 
docker rmi jme-initializer || true

cd /tmp
rm -Rf builder||true

git clone https://github.com/jMonkeyEngine/jme-initializer builder
cd builder

docker build -t jme-initializer .

cd ..
rm -Rf builder||true


docker create --restart=always \
            --name jme-initializer \
            --read-only \
            --tmpfs  /tmp:uid=1000,gid=1000 \
            jme-initializer

docker network connect --alias jme-initializer.docker nginx_gateway_net jme-initializer  
docker network disconnect bridge jme-initializer

docker start jme-initializer