# Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        GitHub Repo                          │
│                                                             │
│   terraform/          gitops/                               │
│   ├─ main.tf          ├─ bootstrap/                         │
│   ├─ providers.tf     └─ apps/                              │
│   └─ variables.tf         ├─ app-of-apps.yaml               │
│                           └─ n8n/                           │
│                               └─ application.yaml           │
└──────────────┬──────────────────────┬───────────────────────┘
               │  terraform apply     │  ArgoCD watches
               ▼                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                        │
│                  (k3d local / EKS on AWS)                   │
│                                                             │
│  ┌─────────────────┐      ┌──────────────────────────────┐  │
│  │   argocd ns     │      │         n8n ns               │  │
│  │                 │ sync │                              │  │
│  │  ArgoCD Server  │─────▶│  n8n Deployment              │  │
│  │  ArgoCD Repo    │      │  n8n Service                 │  │
│  │  ArgoCD App Ctrl│      │  PVC (persistent workflows)  │  │
│  └─────────────────┘      └──────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Traefik Ingress Controller (built into k3d)         │   │
│  │  argocd.localhost:8080  →  ArgoCD UI                 │   │
│  │  n8n.localhost:8080     →  n8n UI                    │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## GitOps Flow

1. You push a change to `gitops/apps/n8n/application.yaml` (e.g. bump chart version)
2. ArgoCD detects the drift within 3 minutes
3. ArgoCD syncs the cluster state to match git — no `kubectl apply` needed
4. If the sync fails, ArgoCD self-heals back to the last known good state

## Extending to AWS EKS

Replace the `null_resource.k3d_cluster` in `terraform/main.tf` with:
- `module "eks"` from `terraform-aws-modules/eks/aws`
- Update `providers.tf` to use the EKS kubeconfig data source
- Everything else (ArgoCD, GitOps manifests) remains identical
