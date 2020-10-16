#!/bin/bash
set -e
source /config.sh
mkdir -p /health
mkdir -p /health/priv
mkdir -p /health/public
useradd -r -s /bin/false health_httpd || true

# Update busybox
apt install -y busybox

# Job that collects health data every 5 minutes
rm -f /healthcollector.sh || true
cp /installers/healthcollector/healthcollector.sh /healthcollector.sh
cp /installers/healthcollector/healthcollector.data /healthcollector.data
chmod +x /healthcollector.sh
(crontab -l ; echo "*/5 * * * * (/healthcollector.sh)") | sort - | uniq - | crontab -


