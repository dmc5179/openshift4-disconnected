# RHDH Platform Template Governance

Enforced software templates for Red Hat Developer Hub (RHDH) where the platform engineering team controls mandatory steps and developers customize projects through parameters only.

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│  PLATFORM ENGINEERING (controls)                            │
│                                                             │
│  template.yaml                                              │
│  ┌────────────────────┐    ┌──────────────────────────────┐ │
│  │  spec.parameters   │    │  spec.steps (MANDATORY)      │ │
│  │  ────────────────   │    │  ──────────────────────────  │ │
│  │  Defines what       │    │  1. Fetch skeleton           │ │
│  │  developers see     │    │  2. Inject security config   │ │
│  │  in the form.       │    │  3. Inject linting rules     │ │
│  │                     │    │  4. Inject CI/CD pipeline    │ │
│  │  Platform team      │    │  5. Inject namespace RBAC    │ │
│  │  decides which      │    │  6. Publish to Git           │ │
│  │  fields exist and   │    │  7. Register in catalog      │ │
│  │  which are required.│    │                              │ │
│  └────────┬───────────┘    │  Developers NEVER see or     │ │
│           │                │  edit these steps.            │ │
│           ▼                └──────────────────────────────┘ │
│  ┌────────────────────┐                                     │
│  │  Developer Form UI │                                     │
│  │  ────────────────── │                                     │
│  │  • Service name *   │  ◄── Developer fills this in       │
│  │  • Owner *          │                                     │
│  │  • Git provider *   │                                     │
│  │  • Enable DB? [ ]   │  ◄── Optional toggle               │
│  │  • Monitoring? [✓]  │  ◄── Optional toggle               │
│  └────────────────────┘                                     │
└─────────────────────────────────────────────────────────────┘
```

**Enforcement layers:**

| Layer | Mechanism | Effect |
|-------|-----------|--------|
| Template YAML | `spec.steps` are hardcoded, execute server-side | Developers cannot skip or alter steps |
| Git ownership | Template repo has branch protection; devs have read-only | Developers cannot modify template source |
| RBAC | Developers lack `catalog.location.create` permission | Developers cannot register rogue templates |
| Parameters | `required` array + `enum` constraints + `pattern` regex | Input validation enforced before steps run |

## Directory Layout

```
rhdh-platform-templates/
├── README.md                          ← You are here
├── 01-operator-config/
│   ├── app-config-rhdh.yaml           ← RHDH ConfigMap (permissions, catalog, integrations)
│   ├── rbac-policy.csv                ← RBAC permission policies (CSV format)
│   ├── backstage-cr-patch.yaml        ← Backstage CR for the Operator
│   └── apply.sh                       ← oc commands to apply all config
├── 02-templates/
│   ├── catalog.yaml                   ← Location entity pointing to templates
│   └── platform-standard-service/
│       ├── template.yaml              ← THE template (parameters + enforced steps)
│       └── skeleton/                  ← Files scaffolded into every new project
│           ├── catalog-info.yaml
│           ├── Dockerfile
│           ├── Makefile
│           ├── .security/
│           │   └── security-scan.yaml
│           ├── .linting/
│           │   ├── .editorconfig
│           │   └── lint-config.yaml
│           ├── .github/workflows/
│           │   └── ci.yaml            ← GitHub Actions pipeline
│           ├── .gitlab/
│           │   └── .gitlab-ci.yml     ← GitLab CI pipeline
│           └── deploy/
│               ├── rbac/
│               │   └── namespace-rbac.yaml
│               ├── database/
│               │   └── postgresql.yaml
│               ├── monitoring/
│               │   └── servicemonitor.yaml
│               └── ingress/
│                   └── route.yaml
└── 03-rbac/
    └── setup-rbac.sh                  ← RBAC setup via oc + RHDH REST API
```

## Prerequisites

- OpenShift cluster with the RHDH Operator installed
- `oc` CLI authenticated to the cluster
- A Git provider account (GitHub and/or GitLab) with a personal access token
- An OpenShift namespace for RHDH (default: `rhdh-operator`)

## Step-by-Step Implementation

### Step 1: Customize Configuration

Edit these placeholder values across the config files:

| Placeholder | File(s) | Replace With |
|-------------|---------|--------------|
| `<CLUSTER_DOMAIN>` | `01-operator-config/app-config-rhdh.yaml` | Your OpenShift apps domain (e.g., `apps.mycluster.example.com`) |
| `<ORG>` | `01-operator-config/app-config-rhdh.yaml` | Your GitHub org or GitLab group |
| `<DOMAIN>` | `01-operator-config/app-config-rhdh.yaml` | Your GitLab domain (if using GitLab) |
| `user:default/platform-admin` | `01-operator-config/app-config-rhdh.yaml` | Your RBAC admin user entity ref |
| `group:default/platform-engineering` | `01-operator-config/rbac-policy.csv` | Your platform team's group entity ref |
| `group:default/developers` | `01-operator-config/rbac-policy.csv` | Your developer group entity ref(s) |

### Step 2: Push Templates to Git

Push this entire repository (or the `02-templates/` directory) to a Git repository that the platform engineering team owns with branch protection enabled.

```bash
# GitHub example
git init
git add .
git commit -m "Initial platform templates"
git remote add origin https://github.com/<ORG>/platform-templates.git
git push -u origin main

# Enable branch protection on main (requires admin)
gh api repos/<ORG>/platform-templates/branches/main/protection \
  -X PUT \
  -f required_pull_request_reviews.required_approving_review_count=1 \
  -F enforce_admins=true
```

For GitLab:
```bash
git remote add origin https://gitlab.<DOMAIN>/<GROUP>/platform-templates.git
git push -u origin main

# Protect the main branch via GitLab UI or API
```

### Step 3: Create the Git Token Secret

```bash
# For GitHub
oc create secret generic rhdh-secrets \
  -n rhdh-operator \
  --from-literal=GITHUB_TOKEN="ghp_your_real_token_here"

# For GitLab
oc create secret generic rhdh-secrets \
  -n rhdh-operator \
  --from-literal=GITLAB_TOKEN="glpat-your_real_token_here"

# For both
oc create secret generic rhdh-secrets \
  -n rhdh-operator \
  --from-literal=GITHUB_TOKEN="ghp_your_real_token_here" \
  --from-literal=GITLAB_TOKEN="glpat-your_real_token_here"
```

### Step 4: Apply the Operator Configuration

```bash
cd 01-operator-config/
./apply.sh rhdh-operator
```

This will:
1. Create the `app-config-rhdh` ConfigMap
2. Create the `rbac-policy` ConfigMap from the CSV file
3. Apply the Backstage CR, which mounts both into the RHDH instance

Wait for the RHDH pod to restart:
```bash
oc get pods -n rhdh-operator -w
```

### Step 5: Configure RBAC (Choose One Method)

**Option A: CSV file (already applied in Step 4)**

The `rbac-policy.csv` is mounted into RHDH via the Backstage CR. Policies take effect on pod restart. This is the recommended method for GitOps workflows.

**Option B: REST API (for dynamic updates)**

```bash
cd 03-rbac/
./setup-rbac.sh rhdh-operator
```

This creates roles and policies via the RHDH permission REST API without requiring a pod restart.

### Step 6: Verify

1. **Log in as a platform engineer** and confirm you can:
   - See the template in the catalog under Self-service
   - Execute the template
   - Register new catalog locations

2. **Log in as a developer** and confirm you can:
   - See and execute the template
   - Fill in the parameter form
   - **Cannot** register new catalog locations or templates
   - **Cannot** see a "Register Existing Component" option (if `catalog.location.create` is denied)

3. **Check RBAC policies are active:**
   ```bash
   # Port-forward to RHDH
   oc port-forward -n rhdh-operator svc/backstage-developer-hub 7007:7007 &

   # List roles
   curl -s http://localhost:7007/api/permission/roles | python3 -m json.tool

   # List policies for a specific role
   curl -s "http://localhost:7007/api/permission/policies/role/default/developers" | python3 -m json.tool
   ```

## What Each Mandatory Step Does

| Step ID | Action | Purpose | Can Developer Skip? |
|---------|--------|---------|---------------------|
| `fetch-skeleton` | `fetch:template` | Scaffolds the project from the platform skeleton | No |
| `inject-security` | `fetch:plain` | Adds security scanning config (Trivy, Gitleaks) | No |
| `inject-linting` | `fetch:plain` | Adds linting rules (Hadolint, yamllint, shellcheck) | No |
| `inject-github-ci` | `fetch:template` | Adds GitHub Actions CI/CD pipeline | No (auto-selected by git provider) |
| `inject-gitlab-ci` | `fetch:template` | Adds GitLab CI pipeline | No (auto-selected by git provider) |
| `inject-namespace-rbac` | `fetch:template` | Adds namespace + RBAC + NetworkPolicy manifests | No |
| `inject-database` | `fetch:template` | Adds PostgreSQL deployment manifests | Yes (toggle in form) |
| `inject-monitoring` | `fetch:template` | Adds Prometheus ServiceMonitor | Yes (toggle in form) |
| `inject-ingress` | `fetch:template` | Adds OpenShift Route | Yes (toggle in form) |
| `publish-github` | `publish:github` | Publishes to GitHub with branch protection | No (auto-selected) |
| `publish-gitlab` | `publish:gitlab` | Publishes to GitLab | No (auto-selected) |
| `register` | `catalog:register` | Registers the new service in the RHDH catalog | No |

## Adding a New Mandatory Step

To add a new enforced step (e.g., a policy-as-code check):

1. Add the step to `02-templates/platform-standard-service/template.yaml` under `spec.steps`:
   ```yaml
   - id: inject-policy
     name: Apply OPA Policy
     action: fetch:plain
     input:
       targetPath: ./policies
       url: ./skeleton/policies
   ```

2. Add any skeleton files under `skeleton/policies/`.

3. Commit, push to the protected template repo, and wait for RHDH to refresh the catalog (or trigger a refresh manually).

Steps without an `if` condition are mandatory. Steps with `if: ${{ parameters.someToggle }}` are developer-optional.

## RBAC Permission Reference

| Permission | Resource Type | Policy | Who Gets It |
|------------|--------------|--------|-------------|
| `scaffolder.action.execute` | `scaffolder-action` | `use` | Platform engineers, Developers |
| `scaffolder.template.parameter.read` | `scaffolder-template` | `read` | Platform engineers, Developers, Viewers |
| `scaffolder.template.step.read` | `scaffolder-template` | `read` | Platform engineers, Developers, Viewers |
| `catalog.entity.create` | — | `create` | Platform engineers, Developers |
| `catalog.location.create` | — | `create` | Platform engineers only |
| `catalog.location.delete` | — | `delete` | Platform engineers only |
| `catalog.entity.delete` | `catalog-entity` | `delete` | Platform engineers only |

The key enforcement: developers get `scaffolder.action.execute` (can use templates) but **not** `catalog.location.create` (cannot register new templates or locations).

## Official Documentation References

- [Customizing RHDH — Software Templates](https://access.redhat.com/documentation/en-us/red_hat_developer_hub/1.10/html-single/customizing_red_hat_developer_hub/index)
- [Authorization in RHDH — RBAC](https://access.redhat.com/documentation/en-us/red_hat_developer_hub/1.10/html-single/authorization_in_red_hat_developer_hub/index)
- [RHDH 1.0 Admin Guide — Permission Policies Table](https://access.redhat.com/documentation/en-us/red_hat_developer_hub/1.0/html-single/administration_guide_for_red_hat_developer_hub/index)
- [RHDH Release Notes](https://access.redhat.com/documentation/en-us/red_hat_developer_hub/1.10/html-single/red_hat_developer_hub_release_notes/index)
