# Configure Red Hat UBI for local Repo

- Using Red Hat Universal Base Images (UBI) offers a way to build your container images on a foundation of Red Hat Enterprise Linux software. 
- Each Red Hat UBI image is pre-configured to point to UBI yum repositories that contain the latest versions of UBI RPM packages. The UBI repositories contain a small subset of the RPM packages of Red Hat Enterprise Linux repositories, but no subscription is needed to update images from packages in the UBI repositories.

- Assumptions:  The UBI images and UBI repository are available in air-gapped environment

- For a list of UBI repos: https://access.redhat.com/articles/4238681

- Log into the registry
```console
podman login -u <username> <registry:port>
```
- Create a working directory
```console
mkdir local-ubi
```
- Create Dockerfile in local-ubi directory with the following content
```yaml
FROM <internal registry fqdn:port>/ubi9/ubi:latest
# Remove default repo and disable subscription-manager
RUN rm /etc/yum.repos.d/* && sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/subscription-manager.conf

# Copy CA to /etc/pki/ca-trust/source/anchors
COPY CA.crt /etc/pki/ca-trust/source/anchors

# Copy ubi9 repo file pointing to new location
COPY ubi9.repo /etc/yum.repos.d/ 
RUN yum update -y && update-ca-trust
 
```
- Create ubi9.repo file in the local-ubi directory
```yaml
[local-baseos]
name=UBI9 Baseos
baseurl=https://<repo.fqdn>/repos/ubi9/baseos
gpgcheck=0
enabled=1

[local-appstream]
name=UBI9 Appstream
baseurl=https://<repo.fqdn>/repos/ubi9/appstream
gpgcheck=0
enabled=1
```

- Build image from ubi-local directory
```console
podman build -t <internal registry fqdn:port>/ubi9/local-ubi:latest .
```

- Push repo to registry
```console
podman push <internal registry fqdn:port>/ubi9/local-ubi:latest
```
