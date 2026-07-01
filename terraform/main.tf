# ── 1. Local k3d cluster ──────────────────────────────────────────────────────
# Requires: k3d installed locally (https://k3d.io)
# For EKS: replace this block with an aws_eks_cluster resource and point
#           providers.tf kube_context at your EKS context.

resource "null_resource" "k3d_cluster" {
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      k3d cluster create ${var.cluster_name} \
        --agents 2 \
        --port "8080:80@loadbalancer" \
        --port "8443:443@loadbalancer" \
        --wait
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "k3d cluster delete ${self.triggers.cluster_name}"
  }
}

# ── 2. ArgoCD via Helm ───────────────────────────────────────────────────────

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }

  depends_on = [null_resource.k3d_cluster]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    file("${path.module}/argocd-values.yaml")
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# ── 3. Bootstrap: App-of-Apps pointing at this repo ──────────────────────────

resource "kubernetes_manifest" "app_of_apps" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "platform-bootstrap"
      namespace = var.argocd_namespace
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = "main"
        path           = "gitops/apps"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.argocd_namespace
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }

  depends_on = [helm_release.argocd]
}
