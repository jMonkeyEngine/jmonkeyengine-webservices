#!/bin/bash 
source /config.sh

echo "Remove stopped containers"
stopped=`docker ps -aq -f status=exited`
for c in $stopped;
do
    name=`docker inspect --format "{{ .Name }}" $c`
    name="${name:1}"
    if [ "$name" != "certbot" ];
    then
     docker rm $name
    fi
done

echo "Remove unused volumes"
docker volume prune --filter "label!=keep" -f

echo "Remove unused images"
docker image prune -a -f 

echo "Clean OS"
journalctl --vacuum-time=10d --vacuum-size=50M
apt --purge autoremove -y
apt autoclean -y
cat /dev/null > /var/log/btmp