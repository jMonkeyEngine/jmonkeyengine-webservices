#!/bin/bash
set -e
source /config.sh

mkdir -p /srv/minio/data
mkdir -p /srv/minio/config

docker stop minio || true
docker rm minio || true
docker pull minio/minio

rm -Rf /srv/minio/config/*.json || true
rm -Rf /srv/minio/config/*.json.* || true

docker run  --restart=always   -d  --name minio \
  -e "MINIO_ACCESS_KEY=$MINIO_MASTER_USERNAME" \
  -e "MINIO_SECRET_KEY=$MINIO_MASTER_PASSWORD" \
  -v /srv/minio/data:/data \
  -v /srv/minio/config:/root/.minio \
  --read-only \
  --tmpfs  /tmp:uid=1000,gid=1000 \
  --health-cmd="curl -f http://localhost:9000/minio/health/live || exit 1" \
  minio/minio server  /data --console-address "9001"

docker network connect --alias minio.docker nginx_gateway_net minio  
docker network disconnect bridge minio
