#!/bin/bash

# Hostnames
export HUB_HOSTNAME="hub.jmonkeyengine.org"
export STORE_HOSTNAME="store.jmonkeyengine.org"
export PMA_HOSTNAME="pma.jmonkeyengine.org"
export SERVER_IP="127.0.0.1"
export SERVER_NAME="jmonkeyengine"


# Archive. Url pointing to an HTTP(s) server used to serve very very old uploads (mostly from the old forum migration).
#   Proxied through the nginx gateway. 
#   This means that the urls will still look as if they were coming from $HUB_HOSTNAME, 
#   meaning this value can change accross instalations without problems.
#   It is also possible to arbitrarily move files served from $HUB_HOSTNAME/uploads/default 
#   into $JME_HISTORIC_ARCHIVE/uploads/default  and they will be served as expected.
#   Note: escaped for sed
export JME_HISTORIC_ARCHIVE='https\://jme\-historic\.frk\.wf'

# Backups config (glacier)
export AWS_ACCESS_KEY_ID="AAAAAAAAAAAa"
export AWS_SECRET_ACCESS_KEY="BBBBBBBBBbb"
export AWS_BUCKET="s3://brr_glacier"
export AWS_BUCKET2="s3://brr_glacier2"

# ROBOT notifications        
export ROBOT_EMAIL="bipboop@iamarob.ot"
export ROBOT_EMAIL_USERNAME="bipboop@iamarob.ot"
export ROBOT_EMAIL_PASSWORD="01010101010101010101"
export ROBOT_SMTP_PORT="587"
export ROBOT_SMTP_HOST="smtp.gmail.com"

# Team email
export TEAM_EMAIL_DEST="contact@jmonkeyengine.org"

# Store
export GIT_STORE_REPO_PRIVATE_KEY="very long ssh key"
export GIT_STORE_REPO_PUBLIC_KEY="public ssh key"
export GIT_STORE_REPO="git@github.com:jMonkeyEngine/SoftwareStore.git"
export GIT_STORE_BRANCH="current"
export STORE_DB_USER="jmestore"
export STORE_DB_PASSWORD=""
export STORE_DB_NAME="jmestore"


# Mysql
export MYSQL_ROOT_PASSWORD="verySecretPassword"
export PMA_HTTP_USER="mySecretUser"
export PMA_HTTP_PASSWORD="mySecretPassword"

# SSL Certs
export SSL_EMAIL="someoneemail@something.something"
export SSL_ROOT="ssl.jmonkeyengine.org"
export SSL_ROOT_NAME="jme" # Can be a fantasy name.

# Healthcheck
export HEALTH_CHECK_PRIV_DATA_PASSPHRASE=""

# CSV list of emails
export HUB_DEVELOPER_EMAILS=""

# Load testing 
export LOADER_IO_VERIFICATION_TOKEN="loaderio-12c626c34599fecb2180d30f2694fb33"

#KEEWEB
export KEEWEB_HOSTNAME="vault.jmonkeyengine.org"
export KEEWEB_HTTP_USER=""
export KEEWEB_HTTP_PASSWORD=""