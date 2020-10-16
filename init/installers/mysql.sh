#!/bin/bash
set -e
source /config.sh

# Maria DB
docker stop mysql || true
docker rm mysql || true
docker pull mariadb

docker create   \
    --read-only \
    --name mysql \
    --restart=always \
    -v /srv/mysql_data:/var/lib/mysql \
    --tmpfs /tmp \
    --tmpfs /run/mysqld \
    -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD"  \
    --health-cmd="mysqladmin ping --silent -u root -p${MYSQL_ROOT_PASSWORD} || exit 1" \
    mariadb 

docker network connect --alias mysql mysql_net mysql  
docker network disconnect bridge mysql


# phpmyadmin
docker stop phpmyadmin || true
docker rm phpmyadmin || true
docker pull phpmyadmin/phpmyadmin

docker create --name phpmyadmin \
--restart=always  \
-e PMA_HOST=mysql  \
--health-cmd="curl -sS -o /dev/null http://127.0.0.1 || exit 1" \
phpmyadmin/phpmyadmin

docker network connect --alias phpmyadmin.mysql mysql_net phpmyadmin  
docker network connect --alias phpmyadmin.docker nginx_gateway_net phpmyadmin  
docker network disconnect bridge phpmyadmin

docker start mysql
docker start phpmyadmin


if [ -f "/srv/mysql_data/markForRestoration.txt" ];
then
    echo "Restore mysql"
    sleep 10
    rm /srv/mysql_data/markForRestoration.txt
    while ! docker exec -i mysql sh -c "exec mysql -uroot -p\"${MYSQL_ROOT_PASSWORD}\"" < /backups/mysql.sql
    do
        echo "Restoration failed. Maybe the container is still starting. Retry"
        sleep 1
    done
    echo "Restored"
fi


