# oc-mirror v2 sample output

Cluster resources that `oc-mirror` v2 (4.20) writes to
`<workspace>/working-dir/cluster-resources/` after mirroring an OCP 4.19
release plus the `redhat-operator-index` catalog. The mirror registry hostname
has been replaced with `registry.example.com:8443`.

| File | Kind | Purpose |
|---|---|---|
| `idms-oc-mirror.yaml` | ImageDigestMirrorSet | Redirects pulls by digest (release payload, operator images) to the mirror |
| `itms-oc-mirror.yaml` | ImageTagMirrorSet | Redirects pulls by tag for the release images |
| `cs-redhat-operator-index-v4-19.yaml` | CatalogSource | OLM v0 catalog pointing at the mirrored index |
| `cc-redhat-operator-index-v4-19.yaml` | ClusterCatalog | OLM v1 equivalent of the CatalogSource |
| `updateService.yaml` | UpdateService | OpenShift Update Service (OSUS) for disconnected upgrades |
| `signature-configmap.yaml` | ConfigMap | Release signature, so the CVO can verify the mirrored release |

Apply the real files from your own run with
`oc apply -f <workspace>/working-dir/cluster-resources/`.

Unlike v1, repeated v2 runs merge into a single IDMS/ITMS instead of writing a
new ICSP per run (see `../sequential-runs/`).
