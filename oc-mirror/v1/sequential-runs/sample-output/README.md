# oc-mirror v1 sample output

oc-mirror v1 is deprecated; use `oc-mirror/v2/`. Kept for reference.

Examples from an oc-mirror v1 `results-*` directory, with the mirror registry
hostname replaced by `registry.example.com:8443`:

- `imageContentSourcePolicy.yaml`: the ICSP v1 writes for operator images.
  ICSP is deprecated in favor of ImageDigestMirrorSet. Every v1 run names it
  `operator-0`, so sequential runs overwrite each other (see `../merge-icsp.sh`).
- `catalogSource-cs-redhat-operator-index.yaml`: the generated CatalogSource,
  edited to pin the index by digest and to add `updateStrategy.registryPoll`
  so the cluster picks up a re-mirrored index without re-applying it.
