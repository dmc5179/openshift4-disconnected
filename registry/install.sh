#!/bin/bash

REGISTRY_DIR=""
REGISTRY_HOSTNAME=""
REGISTRY_PORT=5000

yum -y install podman httpd httpd-tools firewalld skopeo

mkdir -p ${REGISTRY_DIR}/{auth,certs,data}

openssl req -newkey rsa:4096 -nodes -sha256 -keyout ${REGISTRY_DIR}/certs/domain.key -x509 -days 365 -out ${REGISTRY_DIR}/certs/domain.crt

htpasswd -bBc ${REGISTRY_DIR}/auth/htpasswd dummy dummy

#Make sure to trust the self signed cert we just made
sudo cp -f ${REGISTRY_DIR}/certs/domain.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust extract

sudo firewall-cmd --add-port=${REGISTRY_PORT}/tcp --zone=internal --permanent
sudo firewall-cmd --add-port=${REGISTRY_PORT}/tcp --zone=public   --permanent
sudo firewall-cmd --add-service=http  --permanent
sudo firewall-cmd --reload

# Pull down the docker registry image from s3
# and import it into the local container storage
#cd
#mkdir docker-registry
#aws s3 cp --recursive 's3://ocp-4.2.0/images/docker-registry/' docker-registry/
#skopeo copy dir://home/ec2-user/docker-registry/ containers-storage:docker.io/library/registry:2
#rm -rf docker-registry

podman run --name registry_server -p ${REGISTRY_PORT}:5000 \
-v ${REGISTRY_DIR}/data:/var/lib/registry:z \
-v ${REGISTRY_DIR}/auth:/auth:z \
-e "REGISTRY_AUTH=htpasswd" \
-e "REGISTRY_AUTH_HTPASSWD_REALM=Registry" \
-e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry" \
-e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
-v ${REGISTRY_DIR}/certs:/certs:z \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
--hostname=${REGISTRY_HOSTNAME} \
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

# Test the connection
curl -u dummy:dummy https://${REGISTRY_HOSTNAME}:${REGISTRY_PORT}/v2/_catalog
