# n8n GitOps Platform

Self-hosted [n8n](https://n8n.io) workflow automation running on Kubernetes, deployed and managed entirely through GitOps.

**Stack:** Terraform · k3d (local) / EKS (AWS) · ArgoCD · Helm · GitHub Actions

---

## What this does

- Provisions a Kubernetes cluster locally with **k3d** (or AWS EKS — see [docs/architecture.md](docs/architecture.md))
- Installs **ArgoCD** via Helm using Terraform
- Bootstraps an **App-of-Apps** pattern — ArgoCD watches this repo and syncs all declared apps automatically
- Deploys **n8n** via its official Helm chart, managed entirely by ArgoCD
- Any change pushed to `gitops/` is automatically applied to the cluster — no manual `kubectl apply`

```
git push → ArgoCD detects drift → cluster syncs itself
```

---

## Prerequisites

| Tool        | Version  | Install                         |
|-------------|----------|---------------------------------|
| k3d         | ≥ 5.6    | https://k3d.io/#installation    |
| Terraform   | ≥ 1.6    | https://developer.hashicorp.com/terraform/install |
| kubectl     | ≥ 1.28   | https://kubernetes.io/docs/tasks/tools/ |
| Helm        | ≥ 3.14   | https://helm.sh/docs/intro/install/ |

---

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/ramalakshmi0505/n8n-gitops-platform
cd n8n-gitops-platform

# 2. Update your repo URL in terraform/variables.tf
#    gitops_repo_url = "https://github.com/<your-username>/n8n-gitops-platform"

# 3. Provision cluster + ArgoCD + bootstrap app
cd terraform
terraform init
terraform apply

# 4. Add to /etc/hosts (Mac/Linux) or C:\Windows\System32\drivers\etc\hosts (Windows)
echo "127.0.0.1 argocd.localhost n8n.localhost" | sudo tee -a /etc/hosts

# 5. Get ArgoCD initial password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d

# 6. Open UIs
#    ArgoCD: http://argocd.localhost:8080  (user: admin)
#    n8n:    http://n8n.localhost:8080     (user: admin / changeme)
```

Within ~3 minutes ArgoCD will pull the n8n Application manifest from git and deploy n8n automatically.

---

## Project Structure

```
n8n-gitops-platform/
├── terraform/
│   ├── main.tf              # k3d cluster + ArgoCD helm release + bootstrap app
│   ├── providers.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── argocd-values.yaml
├── gitops/
│   ├── bootstrap/           # Namespace manifests
│   └── apps/
│       ├── app-of-apps.yaml # Root ArgoCD Application (watches gitops/apps/)
│       └── n8n/
│           └── application.yaml  # n8n Helm release via ArgoCD
├── .github/
│   └── workflows/
│       └── validate.yml     # Terraform validate + manifest lint + Trivy scan
└── docs/
    └── architecture.md
```

---

## Deploying a Change (GitOps in Action)

To upgrade n8n, edit `gitops/apps/n8n/application.yaml`:

```yaml
targetRevision: 0.26.0   # bump the chart version
```

Commit and push. ArgoCD detects the change and rolls out the upgrade — no manual intervention needed.

---

## Extending to AWS EKS

See [docs/architecture.md](docs/architecture.md) for the EKS swap-out instructions. The GitOps layer (ArgoCD + manifests) is identical — only the cluster provisioning changes.

---

## CI Pipeline

Every PR runs:
- `terraform validate` + format check
- `kubeconform` manifest validation against Kubernetes schemas
- `trivy config` scan for HIGH/CRITICAL misconfigurations

---

## Security Notes

- Change `N8N_BASIC_AUTH_PASSWORD` before exposing n8n outside localhost
- In production: replace basic auth with an SSO provider (Authentik, Keycloak)
- Use HashiCorp Vault or AWS Secrets Manager for secrets instead of the `secret:` block in the Application manifest

---

## License

MIT
