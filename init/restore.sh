#!/bin/bash
set -e
source /config.sh

# Duplicity restore
echo "Restore /srv"
/usr/local/bin/duplicity --force --no-encryption --time 0D  ${AWS_BUCKET1} /srv/

echo "Restore /backups"
/usr/local/bin/duplicity  --force  --no-encryption --time 0D  ${AWS_BUCKET2}  /backups/

mkdir -p  /srv/hub/
mkdir -p /srv/hub_origin
mkdir -p  /srv/mysql_data
bash -c "echo 1 > /srv/hub_origin/markForRestoration.txt"
bash -c "echo 1 > /srv/mysql_data/markForRestoration.txt"    
