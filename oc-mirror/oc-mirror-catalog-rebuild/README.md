# Merging Catalogs

## Get the digest for both catalog images to be merged

- In Quay, browse to your index like myregistry.com:8443/redhat/redhat-operator-index
- Get the digest of the 2 versions of the catalog index that need to be merged

## Create 2 containers from the catalog images

```bash
podman create --name my-catalog-ver-a myregistry.com:8443/redhat/redhat-operator-index@sha256:f.....a

podman create --name my-catalog-ver-b myregistry.com:8443/redhat/redhat-operator-index@sha256:f.....b
```

## Copy the contents of the catalogs out
```bash
podman cp my-catalog-ver-a ./index-catalog-ver-a
podman cp my-catalog-ver-b ./index-catalog-ver-b
```

## Stop the containers
```bash
podman stop my-catalog-ver-a
podman stop my-catalog-ver-b
podman rm my-catalog-ver-a
podman rm my-catalog-ver-b
```

## Locally merge the directories

- rsync is safer but use cp if rsync is not available
```bash
rsync -av ./index-catalog-ver-a ./index-catalog-ver-b new_index
#cp -rn ./index-catalog-ver-a ./index-catalog-ver-b new_index
```

## Rebuild a catalog image

```bash
podman build -t myregistry.com:8443/redhat/redhat-operator-index:v4.21 -f Containerfile .
```

## Push the catalog image

```bash
podman push myregistry.com:8443/redhat/redhat-operator-index:v4.21
```

