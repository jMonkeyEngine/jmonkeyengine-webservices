#!/bin/bash
set -e
source /config.sh

# Phpmyadmin guard password
htpasswd -b -c /srv/nginx_gateway/.pma "${PMA_HTTP_USER}" "${PMA_HTTP_PASSWORD}"


# Keeweb guard password
htpasswd -b -c /srv/nginx_gateway/.keeweb "${KEEWEB_HTTP_USER}" "${KEEWEB_HTTP_PASSWORD}"

# Metrics guard password
htpasswd -b -c /srv/nginx_gateway/.metrics "${METRICS_HTTP_USER}" "${METRICS_HTTP_PASSWORD}"


#Certbot
docker stop certbot || true
docker rm certbot || true
docker pull riccardoblb/certbot:amd64
docker run --name certbot \
    -v /srv/certs:/certs \
    -e "EMAIL=$SSL_EMAIL" \
    -d riccardoblb/certbot:amd64  sleep 3600

docker network connect --alias certbot.docker nginx_gateway_net certbot 
docker network disconnect bridge certbot

#Nginx
docker stop nginx_gateway || true
docker rm nginx_gateway || true
docker pull nginx:stable-alpine

rm -Rf /srv/certs|| true
mkdir -p /srv/certs|| true
cp -Rf /srv/certs_fake/* /srv/certs/
chown 1000:1000 /srv/certs -Rf
chown 1000:1000 /srv/certs_fake -Rf

mkdir -p /srv/keeweb/db/data
chown 1000:1000 -Rf /srv/keeweb/db/data
docker run   --name=nginx_gateway -v /srv/certs:/etc/nginx/certs:ro \
        -v /srv/nginx_gateway:/etc/nginx:ro  \
        -v  /srv/keeweb/db/data:/keeweb \
        -v  /srv/hub/shared/standalone/nginx.http.sock:/var/run/hub.sock \
        --health-cmd="(curl  -sS  http://127.0.0.1:80/health|grep UP) || exit 1" \
        -p 80:80 -p 443:443  --restart=always \
        -d  nginx:stable-alpine

docker network connect --alias nginx_gateway.docker nginx_gateway_net nginx_gateway
docker network disconnect bridge nginx_gateway || true
docker restart nginx_gateway

#Generate SSL certs
sleep 10
docker stop certbot
if [ "$SKIP_CERTS" != "1" ];
then
    sleep 10
    docker start certbot
    docker exec -e "DOMAINS=${SSL_ROOT},${HUB_HOSTNAME},${STORE_HOSTNAME},${PMA_HOSTNAME},${KEEWEB_HOSTNAME},${OBJECT_STORAGE_HOSTNAME},${ARTIFACTS_HOSTNAME},${KEEWEB_WEB_DAV_HOSTNAME},${OBJECT_STORAGE_CONSOLE_HOSTNAME},${METRICS_HOSTNAME},${INITIALIZER_HOSTNAME}"  certbot sh /run.sh new
    docker stop certbot
fi
docker restart nginx_gateway