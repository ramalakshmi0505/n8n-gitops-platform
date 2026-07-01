output "argocd_url" {
  description = "ArgoCD UI"
  value       = "http://argocd.localhost:8080"
}

output "n8n_url" {
  description = "n8n UI"
  value       = "http://n8n.localhost:8080"
}

output "argocd_initial_password_command" {
  description = "Run this to get the initial ArgoCD admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}
