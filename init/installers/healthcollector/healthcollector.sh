#!/bin/bash
set -e
source /config.sh

# Reset health infos
rm -Rf /health/priv/* || true
rm -Rf /health/public/* || true
mkdir -p /health/priv
mkdir -p /health/public

# Public health info
## Discourse
( ( curl  -sS "https://$HUB_HOSTNAME/srv/status" | grep -q ok ) && echo '{"Status":"healthy"}' || echo '{"Status":"unhealthy"}' ) >  /health/public/hub.container.health.txt

## Other docker containers
while read containerName; do
    d="/health/public/$containerName.container.health.txt"
    echo '{"Status":"unhealthy"}' > "$d"
done </healthcollector.data

containers=`docker ps -q `
for c in $containers; 
do 
    containerName="`docker inspect --format="{{.Name}}" $c`"
    containerName="${containerName:1}"
    if [ "$containerName" = "app" ]; then continue; fi # discourse status already collected

    d="/health/public/$containerName.container.health.txt"
    if [ -f "$d" ];
    then        
        health="`docker inspect --format='{{json .State.Health}}'  $c`"
        echo "$health" >  "$d"
    fi
done

# Protected health info
## Copy public health infos
cp /health/public/*.health.txt /health/priv/

## Get disk usage
( df -kP  | awk '{print $1","$2","$3","$4","$5","$6" "$7}' ) > /health/priv/disks.health.txt

## Get available memory
total=`( free -b  | grep ^Mem | tr -s ' ' | cut -d ' ' -f 2 )`
used=`( free -b  | grep ^Mem | tr -s ' ' | cut -d ' ' -f 3 )`
available=`expr $total - $used`
echo "$available" > /health/priv/memory-available.health.txt


# Create index
cd /health/public
ls -1 > index.txt

cd /health/priv
ls -1 > index.txt

# Set permissions
chown  -Rf  health_httpd:health_httpd /health/public
chown  -Rf  health_httpd:health_httpd /health/priv


# HTTP server that exposes public and private data
authHash="`(busybox httpd -m ${HEALTH_CHECK_PRIV_DATA_PASSPHRASE})`"

killall -u health_httpd || true
echo "/:monitor:$authHash" > /health/priv.conf
cd /health/public
busybox httpd -u health_httpd -p 4444 
cd /health/priv
busybox httpd -u health_httpd -p 4445 -r 'Authorize' -c /health/priv.conf
