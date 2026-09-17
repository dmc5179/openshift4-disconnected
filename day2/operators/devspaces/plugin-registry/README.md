# Dev Spaces Plugin Registry for disconnected systems

## Clone repo

```bash
git clone https://github.com/redhat-developer/che-plugin-registry.git
```

## modify openvsx-sync.json

## Build the plugin registry container image
```bash
./build.sh --registry quay.io --organization danclark --tag latest
```

## Mirror container to disconnected side

- bring the container and the "patch-cluster.sh" script or the entire git repo

## Patch the che cluster
```bash
./patch-cluster.sh
```
