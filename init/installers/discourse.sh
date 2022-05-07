#!/bin/bash
set -e
source /config.sh

rm -Rf /srv/hub/shared/standalone/nginx.http.sock || true

if [ ! -f "/srv/hub/launcher" ];
then
    echo "Discourse doesn't exist! Install"
    mkdir -p  /srv/hub/
    git clone https://github.com/discourse/discourse_docker.git /srv/hub/
fi
cp -f /srv/hub_origin/app.yml /srv/hub/containers/app.yml

/cleanup.sh

echo "Update hub!"
cd  /srv/hub/
git pull
./launcher rebuild app
/cleanup.sh
./launcher rebuild app # Sometimes you need to do this twice... 

yes | ./launcher cleanup
/cleanup.sh

mkdir -p /backups/hub/default
mkdir -p /srv/hub/shared/standalone/backups/default

if [ -f "/srv/hub_origin/markForRestoration.txt" ];
then
    echo "Restore the hub"
    sleep 10
    rm /srv/hub_origin/markForRestoration.txt
    mkdir -p  /backups/hub/default
    inPath="`ls  /backups/hub/default/robot_backup-*.gz`"
    while !  docker exec -w /var/www/discourse -i app discourse enable_restore
    do
        echo "Restoration failed. Maybe the container is still starting. Retry"
        sleep 1
    done
    docker exec -w /var/www/discourse -i app discourse restore `basename $inPath`
    echo "Restored"
    yes | ./launcher cleanup
    echo "Cleaned"
fi

yes | ./launcher cleanup
/cleanup.sh

docker update --restart=always app

docker network connect --alias app.docker nginx_gateway_net app  
docker network disconnect bridge app || true
