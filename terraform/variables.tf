variable "kube_context" {
  description = "kubectl context to use (k3d-n8n-platform for local, or your EKS context)"
  type        = string
  default     = "k3d-n8n-platform"
}

variable "cluster_name" {
  description = "Name of the k3d cluster"
  type        = string
  default     = "n8n-platform"
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "6.7.3"
}

variable "n8n_namespace" {
  description = "Namespace for n8n"
  type        = string
  default     = "n8n"
}

variable "gitops_repo_url" {
  description = "URL of YOUR forked GitHub repository"
  type        = string
  default     = "https://github.com/ramalakshmi0505/n8n-gitops-platform"
}
