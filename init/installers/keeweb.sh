#!/bin/bash
set -e
source /config.sh

docker stop keeweb || true
docker rm keeweb || true
docker pull antelle/keeweb

docker run --name keeweb --restart=always  \
-v/srv/keeweb/config:/keeweb/config \
-eKEEWEB_CONFIG_URL="${KEEWEB_HOSTNAME}/config/config.json" \
-d  \
antelle/keeweb

docker network connect --alias keeweb.docker nginx_gateway_net keeweb  
docker network disconnect bridge keeweb
