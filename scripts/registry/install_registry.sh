#!/bin/bash -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  
# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

export REGISTRY_DIR="${HOME}/registry/"
export REGISTRY_HOSTNAME="${HOSTNAME}"
export REGISTRY_IP="$(hostname -i)"
export REGISTRY_PORT=5000
export REGISTRY_IMG="docker.io/library/registry:2"

# User and Group that the systemd service will run as
export REG_USER=$(id -un)
export REG_GROUP=$(id -gn)

sudo yum -y install podman httpd httpd-tools firewalld skopeo

mkdir -p ${REGISTRY_DIR}/{auth,certs,data}

# Not all version of openssl support the addext option for SANs
if openssl req --help 2>&1 | grep -q addext
then
  openssl req -newkey rsa:4096 -nodes -keyout "${REGISTRY_DIR}/certs/registry.key" \
    -x509 -days 365 -out "${REGISTRY_DIR}/certs/registry.crt" \
    -addext "subjectAltName = IP:${REGISTRY_IP},DNS:${HOSTNAME}" \
    -subj "/C=US/ST=VA/L=Chantilly/O=RedHat/OU=RedHat/CN=${HOSTNAME}/"
else
  openssl req -newkey rsa:4096 -nodes -keyout "${REGISTRY_DIR}/certs/registry.key" \
    -x509 -days 365 -out "${REGISTRY_DIR}/certs/registry.crt" \
    -subj "/C=US/ST=VA/L=Chantilly/O=RedHat/OU=RedHat/CN=${HOSTNAME}/"
fi

# Print the certificate
openssl x509 -in "${REGISTRY_DIR}/certs/registry.crt" -text -noout

htpasswd -bBc ${REGISTRY_DIR}/auth/htpasswd dummy dummy

#Make sure to trust the self signed cert we just made
sudo cp -f ${REGISTRY_DIR}/certs/registry.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
sudo update-ca-trust extract

sudo firewall-cmd --add-port=${REGISTRY_PORT}/tcp --zone=internal --permanent
sudo firewall-cmd --add-port=${REGISTRY_PORT}/tcp --zone=public   --permanent
sudo firewall-cmd --add-service=http  --permanent
sudo firewall-cmd --reload

# Stop and remove existing container. Ignore errors if it is not running or not there
podman stop registry_server || true
podman rm registry_server || true

podman run --name registry_server -p ${REGISTRY_PORT}:5000 \
-v ${REGISTRY_DIR}/data:/var/lib/registry:z \
-v ${REGISTRY_DIR}/auth:/auth:z \
-e "REGISTRY_AUTH=htpasswd" \
-e "REGISTRY_AUTH_HTPASSWD_REALM=Registry" \
-e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry" \
-e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
-v ${REGISTRY_DIR}/certs:/certs:z \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
-e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
--hostname=${REGISTRY_HOSTNAME} \
--conmon-pidfile=/tmp/podman-registry-conman.pid \
--detach \
"${REGISTRY_IMG}"

# Configure SELinux to allow containers in systemd services
sudo setsebool -P container_manage_cgroup on

sudo bash -c "cat <<EOF >> /etc/systemd/system/registry-container.service

[Unit]
Description=Container Registry

[Service]
Restart=always
ExecStart=/usr/bin/podman start -a registry_server
ExecStop=/usr/bin/podman stop -t 15 registry_server
User=${REG_USER}
Group=${REG_GROUP}

[Install]
WantedBy=local.target

EOF"

sudo systemctl daemon-reload
sudo systemctl enable registry-container.service

# Test the connection
echo "Testing connection by hostname:"
curl -u dummy:dummy https://${REGISTRY_HOSTNAME}:${REGISTRY_PORT}/v2/_catalog

echo 'Testing connection by IP Address'
curl -u dummy:dummy https://${REGISTRY_IP}:${REGISTRY_PORT}/v2/_catalog
