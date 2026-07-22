# RHDH Platform Template Governance

Platform-enforced software templates for Red Hat Developer Hub. Platform engineering defines mandatory scaffolder steps; developers customize through parameters only.

## What This Repo Is

An implementation kit for RHDH template governance on OpenShift (Operator deployment). Contains operator config, an enforced software template with skeleton, and RBAC setup scripts. Not a library or application — it's a set of YAMLs, shell scripts, and deploy manifests meant to be customized and applied to a cluster.

## Layout

| Path | Purpose |
|------|---------|
| `01-operator-config/` | RHDH ConfigMap (`app-config-rhdh.yaml`), RBAC CSV (`rbac-policy.csv`), Backstage CR (`backstage-cr-patch.yaml`), and `apply.sh` |
| `02-templates/` | Software Template YAML + skeleton directory (Dockerfile, Makefile, CI/CD, security, linting, deploy manifests) |
| `02-templates/catalog.yaml` | Location entity — tells RHDH where to find templates |
| `02-templates/platform-standard-service/template.yaml` | The main template definition: `spec.parameters` (developer form) and `spec.steps` (enforced actions) |
| `02-templates/platform-standard-service/skeleton/` | Nunjucks-templated files scaffolded into every new project |
| `03-rbac/` | `setup-rbac.sh` — creates RBAC roles/policies via the RHDH REST API |
| `README.md` | Full implementation guide with architecture, steps, and verification |

## Key Concepts

- **`spec.steps`** in `template.yaml` execute server-side and cannot be modified by developers at runtime. Steps without an `if` condition are always mandatory.
- **`spec.parameters`** define the developer-facing form. The platform team controls which fields exist, which are `required`, and what values are allowed (`enum`, `pattern`).
- **RBAC enforcement**: developers get `scaffolder.action.execute` (can use templates) but not `catalog.location.create` (cannot register competing templates). This is configured in `rbac-policy.csv`.
- **Git provider**: template supports both GitHub and GitLab — the developer selects via a `gitProvider` parameter, and conditional steps (`if`) handle the provider-specific CI/CD and publish actions.

## Conventions

- All YAML files use the Backstage scaffolder `v1beta3` API version.
- Skeleton files use Nunjucks templating: `${{ values.varName }}` for simple substitution, `{% if values.flag %}...{% endif %}` for conditionals.
- Namespace defaults to the service name if the developer leaves `openshiftNamespace` blank (handled via Nunjucks `{% if %}` in deploy manifests).
- Placeholder tokens (`<CLUSTER_DOMAIN>`, `<ORG>`, `<DOMAIN>`) in `01-operator-config/` must be replaced before applying. The `apply.sh` script does not substitute these — do it manually or with `sed`.

## Working With Templates

When modifying `template.yaml`:

- Add mandatory steps **without** an `if` condition — they always execute.
- Add developer-optional steps **with** `if: ${{ parameters.toggleName }}` and a corresponding boolean parameter.
- Steps reference skeleton content via relative `url:` paths (e.g., `url: ./skeleton/.security`).
- Step outputs chain via `${{ steps['step-id'].output.fieldName }}`.
- The `publish-github` / `publish-gitlab` and `register` steps must remain last — they depend on all prior content being staged.

When modifying skeleton files:

- Use `${{ values.varName }}` (not `${{ parameters.varName }}`) — the `fetch:template` action maps `parameters` to `values` via its `input.values` block.
- Test templates locally using the RHDH Template Editor (Catalog > Self-service > Template Editor).

## Scripts

- `01-operator-config/apply.sh [NAMESPACE]` — applies ConfigMap, RBAC CSV ConfigMap, and Backstage CR. Default namespace: `rhdh-operator`.
- `03-rbac/setup-rbac.sh [NAMESPACE]` — creates RBAC roles and policies via the RHDH REST API (port-forwards to the RHDH pod). Alternative to the CSV method.

Both scripts require `oc` authenticated to the target cluster.

## Verification

After applying, confirm enforcement:

```bash
# Check RHDH pod is running
oc get pods -n rhdh-operator -l app.kubernetes.io/name=backstage

# Port-forward and check RBAC
oc port-forward -n rhdh-operator svc/backstage-developer-hub 7007:7007 &
curl -s http://localhost:7007/api/permission/roles | python3 -m json.tool
curl -s "http://localhost:7007/api/permission/policies/role/default/developers" | python3 -m json.tool
```

Then log in as a developer and verify: can execute templates, cannot register new locations or templates.

## Reference Docs

- [RHDH Customizing — Software Templates](https://access.redhat.com/documentation/en-us/red_hat_developer_hub/1.10/html-single/customizing_red_hat_developer_hub/index)
- [RHDH Authorization — RBAC & Permission Policies](https://access.redhat.com/documentation/en-us/red_hat_developer_hub/1.10/html-single/authorization_in_red_hat_developer_hub/index)
- [RHDH Admin Guide — Scaffolder Permissions Table](https://access.redhat.com/documentation/en-us/red_hat_developer_hub/1.0/html-single/administration_guide_for_red_hat_developer_hub/index)
