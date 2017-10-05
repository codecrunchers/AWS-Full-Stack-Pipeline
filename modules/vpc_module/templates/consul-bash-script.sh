#!/bin/bash
sudo yum -y update
sudo yum -y install aws-cli
export DNS_UPSTREAM=$(cat /etc/resolv.conf | grep -o "^nameserver.*" | cut -d' ' -f2)
echo "$DNS_UPSTREAM" > /tmp/dnsupstream.txt
$(aws ecr get-login --no-include-email --region ${vpc_region})
docker run -d --restart=always -p 8300:8300 -p 8301:8301 -p 8301:8301/udp \
    --net=host \
    -p 8302:8302 -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p 53:53/udp \
    -v /opt/consul:/data \
    -h $(curl -s http://169.254.169.254/latest/meta-data/instance-id) \
    --name consul-server 492333042402.dkr.ecr.eu-west-1.amazonaws.com/tmp-pipeline/consul:latest -server -bootstrap \
    -dc "${vpc_region}" \
    -advertise $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) \
    -ui-dir "/ui" -recursor "$DNS_UPSTREAM"
