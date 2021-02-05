#!/bin/bash
set -e
cd /installers
./mysql.sh
./discourse.sh
./store.sh
./nginx.sh
./healthcollector-inst.sh
./keeweb.sh
./minio.sh
echo "Everything is installed!"
