#!/bin/bash
set -e
source /config.sh

docker stop keeweb || true
docker rm keeweb || true
docker pull antelle/keeweb
mkdir -p /srv/keeweb/config

docker run --name keeweb --restart=always  \
-v/srv/keeweb/config:/keeweb/config \
-eKEEWEB_CONFIG_URL="https://${KEEWEB_HOSTNAME}/config/config.json" \
-d  \
antelle/keeweb

docker network connect --alias keeweb.docker nginx_gateway_net keeweb  
docker network disconnect bridge keeweb


mkdir -p ~/.config/rclone/
echo "[gdrive-secrets]
type = drive
client_id = ${KEEWEB_SECRETS_GDRIVE_CLIENT_ID}
client_secret = ${KEEWEB_SECRETS_GDRIVE_SECRET}
scope = drive.file
root_folder_id = ${KEEWEB_SECRETS_GDRIVE_FOLDER_ID}
token = ${KEEWEB_SECRETS_GDRIVE_TOKEN}
team_drive = 
" > ~/.config/rclone/secrets-rclone.conf 

mkdir -p /srv/keeweb/db/data
umount /srv/keeweb/db/data || true
rclone --config="$HOME/.config/rclone/secrets-rclone.conf" mount --gid 1000 --uid 1000 --allow-other   --umask=0  --daemon gdrive-secrets:/ /srv/keeweb/db/data

