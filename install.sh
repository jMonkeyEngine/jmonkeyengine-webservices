#!/bin/bash
source config.sh

# Create machine
set +e
 docker-machine create -d generic --generic-ip-address $SERVER_IP \
    --generic-ssh-user root --generic-ssh-port 22\
    --generic-ssh-key ~/.ssh/id_rsa \
      $SERVER_NAME
 eval "`docker-machine env $SERVER_NAME`"
 set -e


# Copy init
for f in init/*;
do
    docker-machine scp -r $f $SERVER_NAME:/
done
docker-machine scp config.sh $SERVER_NAME:/

# Permissions
docker-machine ssh  $SERVER_NAME  chmod +x /cleanup.sh
docker-machine ssh  $SERVER_NAME  chmod +x /config.sh
docker-machine ssh  $SERVER_NAME  chmod +x /backup.sh
docker-machine ssh  $SERVER_NAME  chmod +x /setup.sh
docker-machine ssh  $SERVER_NAME  chmod +x /restore.sh
docker-machine ssh  $SERVER_NAME chmod +x /installers/*.sh


# Setup if needed
if [ "$HOST_SETUP" = "1" ];
then
    set +e
    echo "Removing left overs. Don't worry about errors in this section."
    # Special stop for docker
    if [ -f "/srv/hub/launcher" ];
    then
        cdir="$PWD"
        cd /srv/hub/
        ./launcher stop app
        cd "$cdir"
    fi
    docker stop $(docker ps -a -q)
    docker rm $(docker ps -a -q)
    docker network rm `docker network ls -q`
    docker rmi -f `docker images -qa `
    echo "Done! Now you need to worry about errors :)"
    set -e

  docker-machine ssh  $SERVER_NAME service docker stop
  docker-machine ssh  $SERVER_NAME chmod +x /setup.sh
  docker-machine ssh  $SERVER_NAME /setup.sh
  docker-machine ssh  $SERVER_NAME service docker start

  if [ "$NO_RESTART" = ""  ];
    then
        docker-machine ssh $SERVER_NAME reboot || true
        while ! docker-machine ssh $SERVER_NAME whoami;
        do
            echo "Wait for machine to reboot"
            sleep 1
        done
    fi

fi



# Pre Install
docker-machine ssh  $SERVER_NAME mkdir -p /srv

# Restore
if [ "$RESTORE" = "1" ];
then
    docker-machine ssh $SERVER_NAME /restore.sh
fi

# Mysql
docker network create -d bridge --subnet 172.18.0.0/24 mysql_net    || true

# Store
docker-machine ssh $SERVER_NAME mkdir -p /srv/store_data/
docker-machine ssh $SERVER_NAME mkdir -p /srv/store_data/config
docker-machine scp -r config/store/server-config.json  $SERVER_NAME:/srv/store_data/config/server-config.json
docker-machine ssh $SERVER_NAME sed -i "s/%%ROBOT_EMAIL%%/$ROBOT_EMAIL/g" /srv/store_data/config/server-config.json
docker-machine ssh $SERVER_NAME sed -i "s/%%ROBOT_EMAIL_USERNAME%%/$ROBOT_EMAIL_USERNAME/g" /srv/store_data/config/server-config.json
docker-machine ssh $SERVER_NAME sed -i "s/%%ROBOT_EMAIL_PASSWORD%%/$ROBOT_EMAIL_PASSWORD/g" /srv/store_data/config/server-config.json
docker-machine ssh $SERVER_NAME sed -i "s/%%TEAM_EMAIL_DEST%%/$TEAM_EMAIL_DEST/g" /srv/store_data/config/server-config.json
docker-machine ssh $SERVER_NAME sed -i "s/%%ROBOT_SMTP_PORT%%/$ROBOT_SMTP_PORT/g" /srv/store_data/config/server-config.json
docker-machine ssh $SERVER_NAME sed -i "s/%%ROBOT_SMTP_HOST%%/$ROBOT_SMTP_HOST/g" /srv/store_data/config/server-config.json
docker-machine ssh $SERVER_NAME sed -i "s/%%STORE_HOSTNAME%%/$STORE_HOSTNAME/g" /srv/store_data/config/server-config.json
docker-machine ssh $SERVER_NAME sed -i "s/%%STORE_DB_USER%%/$STORE_DB_USER/g" /srv/store_data/config/server-config.json
docker-machine ssh $SERVER_NAME sed -i "s/%%STORE_DB_NAME%%/$STORE_DB_NAME/g" /srv/store_data/config/server-config.json
docker-machine ssh $SERVER_NAME sed -i "s/%%STORE_DB_PASSWORD%%/$STORE_DB_PASSWORD/g" /srv/store_data/config/server-config.json


# NGINX
docker network create -d bridge --subnet 172.18.1.0/24 nginx_gateway_net  || true

## Certs
docker-machine ssh $SERVER_NAME mkdir -p /srv/certs
docker-machine ssh $SERVER_NAME chown 1000:1000 /srv/certs -Rf

# Create place holder certs (we don't really care about the infos, they are just used to bootstrap the server)
docker-machine ssh $SERVER_NAME mkdir -p /srv/certs_fake
docker-machine ssh $SERVER_NAME openssl req -x509 -nodes -days 99999 \
-newkey rsa:1024  \
-subj "/C=IT/ST=IT/L=IT/O=$SSL_ROOT_NAME/CN=$SSL_ROOT" \
-keyout /srv/certs_fake/privkey.pem \
-out /srv/certs_fake/fullchain.pem
docker-machine ssh $SERVER_NAME chown 1000:1000 /srv/certs_fake -Rf

## Nginx conf
docker-machine ssh $SERVER_NAME mkdir -p /srv/www
docker-machine scp -r www  $SERVER_NAME:/srv/
docker-machine scp -r config/nginx_gateway  $SERVER_NAME:/srv/
docker-machine ssh $SERVER_NAME sed -i "s/%%STORE_HOSTNAME%%/$STORE_HOSTNAME/g" /srv/nginx_gateway/nginx.conf
docker-machine ssh $SERVER_NAME sed -i "s/%%PMA_HOSTNAME%%/$PMA_HOSTNAME/g" /srv/nginx_gateway/nginx.conf
docker-machine ssh $SERVER_NAME sed -i "s/%%HUB_HOSTNAME%%/$HUB_HOSTNAME/g" /srv/nginx_gateway/nginx.conf
docker-machine ssh $SERVER_NAME sed -i "s+%%JME_HISTORIC_ARCHIVE%%+$JME_HISTORIC_ARCHIVE+g" /srv/nginx_gateway/nginx.conf
docker-machine ssh $SERVER_NAME sed -i "s+%%LOADER_IO_VERIFICATION_TOKEN%%+$LOADER_IO_VERIFICATION_TOKEN+g" /srv/nginx_gateway/nginx.conf

# Discourse
docker-machine ssh $SERVER_NAME mkdir -p /srv/hub_origin
docker-machine scp -r config/hub/app.yml  $SERVER_NAME:/srv/hub_origin/app.yml
docker-machine ssh $SERVER_NAME sed -i "s/%%HUB_HOSTNAME%%/$HUB_HOSTNAME/g" /srv/hub_origin/app.yml
docker-machine ssh $SERVER_NAME sed -i "s/%%TEAM_EMAIL_DEST%%/$TEAM_EMAIL_DEST/g" /srv/hub_origin/app.yml
docker-machine ssh $SERVER_NAME sed -i "s/%%ROBOT_SMTP_PORT%%/$ROBOT_SMTP_PORT/g" /srv/hub_origin/app.yml
docker-machine ssh $SERVER_NAME sed -i "s/%%ROBOT_EMAIL%%/$ROBOT_EMAIL/g" /srv/hub_origin/app.yml
docker-machine ssh $SERVER_NAME sed -i "s/%%ROBOT_EMAIL_USERNAME%%/$ROBOT_EMAIL_USERNAME/g" /srv/hub_origin/app.yml
docker-machine ssh $SERVER_NAME sed -i "s/%%ROBOT_EMAIL_PASSWORD%%/$ROBOT_EMAIL_PASSWORD/g" /srv/hub_origin/app.yml
docker-machine ssh $SERVER_NAME sed -i "s/%%HUB_DEVELOPER_EMAILS%%/$HUB_DEVELOPER_EMAILS/g" /srv/hub_origin/app.yml
docker-machine ssh $SERVER_NAME sed -i "s/%%ROBOT_SMTP_HOST%%/$ROBOT_SMTP_HOST/g" /srv/hub_origin/app.yml


if [ "$INSTALL" = "" ];
then
    export INSTALL="all"
fi

if [ "$INSTALL" = "all" ];
then
    docker-machine ssh $SERVER_NAME "SKIP_CERTS=$SKIP_CERTS /installers/updater.sh"
else
    if [ ! -f "init/installers/$INSTALL.sh" ];
    then
        echo "Error, can't install $INSTALL. Service not found in init/installers"
    else
        echo "Install $INSTALL"
        docker-machine ssh $SERVER_NAME "SKIP_CERTS=$SKIP_CERTS /installers/$INSTALL.sh"
    fi
fi
