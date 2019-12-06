#!/bin/bash

yum -y install podman httpd httpd-tools firewalld skopeo

mkdir -p /opt/registry/{auth,certs,data}

cd /opt/registry/certs

openssl req -newkey rsa:4096 -nodes -sha256 -keyout domain.key -x509 -days 365 -out domain.crt

htpasswd -bBc /opt/registry/auth/htpasswd dummy dummy

#Make sure to trust the self signed cert we just made
cp /opt/registry/certs/domain.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract

firewall-cmd --add-port=5000/tcp --zone=internal --permanent
firewall-cmd --add-port=5000/tcp --zone=public   --permanent
firewall-cmd --add-service=http  --permanent
firewall-cmd --reload

# Pull down the docker registry image from s3
# and import it into the local container storage
cd
mkdir docker-registry
aws s3 cp --recursive 's3://ocp-4.2.0/images/docker-registry/' docker-registry/
skopeo copy dir://home/ec2-user/docker-registry/ containers-storage:docker.io/library/registry:2
rm -rf docker-registry

podman run --name registry_server -p 5000:5000 \
-v /opt/registry/data:/var/lib/registry:z \
-v /opt/registry/auth:/auth:z \
-e "REGISTRY_AUTH=htpasswd" \
-e "REGISTRY_AUTH_HTPASSWD_REALM=Registry" \
-e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry" \
-e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
-v /opt/registry/certs:/certs:z \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
--detach \
docker.io/library/registry:2

# Configure SELinux to allow containers in systemd services
setsebool -P container_manage_cgroup on

cat <<EOF >> /etc/systemd/system/registry-container.service

[Unit]
Description=Container Registry

[Service]
Restart=always
ExecStart=/usr/bin/podman start -a registry_server
ExecStop=/usr/bin/podman stop -t 15 registry_server

[Install]
WantedBy=local.target

EOF

systemctl enable registry-container.service

