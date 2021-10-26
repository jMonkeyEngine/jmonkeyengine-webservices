#!/bin/bash
source config.sh
set -e
docker-machine ssh  $SERVER_NAME /gdrive-backup.sh $@