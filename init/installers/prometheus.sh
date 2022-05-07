set -e
source /config.sh

#Pushgateway
docker stop prometheus-push || true
docker rm prometheus-push || true
docker pull prom/pushgateway

mkdir -p /srv/prometheus-pushgateway

chown 65534 /srv/prometheus-pushgateway -Rf

docker run -d --name=prometheus-push  --restart=always\
    -v /srv/prometheus-pushgateway:/data \
    prom/pushgateway
    
docker network connect --alias prometheus-push.docker nginx_gateway_net prometheus-push 
docker network disconnect bridge prometheus-push||true

# Node exporter
docker stop system-metrics||true
docker rm system-metrics||true
docker pull   quay.io/prometheus/node-exporter:latest 

docker run  -h jme.system.metrics --restart=always --name=system-metrics -d \
  --net="host" \
  --pid="host" \
  --read-only \
--tmpfs /xbin:exec \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter:latest \
  --path.rootfs=/host --collector.systemd --collector.processes

metrics_host="localhost:9100"
curl_path="/xbin/curl"
docker exec -uroot  system-metrics wget "https://github.com/moparisthebest/static-curl/releases/download/v7.77.0/curl-amd64" -O /xbin/curl
docker exec -uroot   system-metrics chmod +x /xbin/curl
docker exec -d system-metrics sh -c "while true; do $curl_path -s $metrics_host/metrics | $curl_path -u $METRICS_HTTP_USER:$METRICS_HTTP_PASSWORD --data-binary @- https://$METRICS_HOSTNAME/metrics/job/node-exporter/instance/\`hostname\`;sleep 60;done"



# Docker exporter
docker stop docker-metrics||true
docker rm docker-metrics||true
docker pull  prometheusnet/docker_exporter  
docker run  -h jme.docker.metrics --restart=always --name=docker-metrics -d \
--read-only \
--tmpfs /xbin:exec \
--tmpfs /tmp \
-v"/var/run/docker.sock":"/var/run/docker.sock" \
prometheusnet/docker_exporter  

metrics_host="localhost:9417"
curl_path="/xbin/curl"
docker exec -uroot  docker-metrics wget "https://github.com/moparisthebest/static-curl/releases/download/v7.77.0/curl-amd64" -O /xbin/curl
docker exec -uroot   docker-metrics chmod +x /xbin/curl
docker exec -d docker-metrics sh -c "while true; do $curl_path -s $metrics_host/metrics | $curl_path -u $METRICS_HTTP_USER:$METRICS_HTTP_PASSWORD --data-binary @- https://$METRICS_HOSTNAME/metrics/job/docker-exporter/instance/\`hostname\`;sleep 60;done"

