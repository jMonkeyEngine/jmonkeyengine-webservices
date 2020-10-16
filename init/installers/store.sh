#!/bin/bash
set -e
source /config.sh


docker stop store || true
docker rm store || true


cdir="$PWD"

rm -Rf /tmp/store_builder
mkdir -p /tmp/store_builder

echo "$GIT_STORE_REPO_PRIVATE_KEY" > /tmp/store_builder.rsa
chmod 400 /tmp/store_builder.rsa
ssh-keygen -F github.com || ssh-keyscan github.com >> ~/.ssh/known_hosts

cd /tmp/store_builder
git clone  --depth 1 --single-branch --branch current  -c core.sshCommand="/usr/bin/ssh -i /tmp/store_builder.rsa" git@github.com:jMonkeyEngine/SoftwareStore.git .
./build-docker.sh
cd "$cdir"

rm -Rf /tmp/store_builder
rm /tmp/store_builder.rsa

mkdir -p /srv/store_data/config
mkdir -p /srv/store_data/uploaded_images
chown 1000:1000  /srv/store_data/ -Rf
docker create --restart=always \
            --name store \
            --read-only \
            -v"/srv/store_data/config":/app/config \
            -v"/srv/store_data/uploaded_images":/app/www/images/database \
            --tmpfs  /app/sitemap:uid=1000,gid=1000 \
            --tmpfs  /tmp/apptmp:uid=1000,gid=1000 \
            --health-cmd="(curl  -sS  http://127.0.0.1:8080/actuator/health|grep UP) || exit 1" \
            jmestore

docker network connect --alias store.mysql mysql_net store  
docker network connect --alias store.docker nginx_gateway_net store  
docker network disconnect bridge store

docker start store