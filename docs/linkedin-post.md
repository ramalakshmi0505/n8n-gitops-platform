# LinkedIn Post Draft

---

At BMW TechWorks I run n8n workflow automation for multiple business units on top of a multi-region EKS platform. A few people have asked how we manage it without things drifting out of control.

The short answer: GitOps. Nothing touches the cluster directly. Everything goes through git.

I built a minimal open-source version of that setup so you can try it yourself:

→ Terraform provisions a local Kubernetes cluster (k3d) and installs ArgoCD
→ ArgoCD watches the GitHub repo and syncs automatically on every push
→ n8n deploys via its Helm chart, managed entirely by ArgoCD
→ No manual kubectl apply — ever

The whole thing comes up in under 10 minutes on your laptop. Swap k3d for EKS and the GitOps layer stays identical.

What I find useful about this pattern: when something breaks at 2am, you don't guess what changed. You look at the git log.

Repo link in the comments.

#DevOps #Kubernetes #GitOps #ArgoCD #n8n #Terraform #PlatformEngineering #OpenSource

---
