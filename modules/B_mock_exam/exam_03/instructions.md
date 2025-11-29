# Mock Exam #3 – GitOps with ArgoCD & Kustomize

## Scenario
You must ship a small web service using GitOps. Use Kustomize for environment overlays and ArgoCD to continuously deploy to a cluster.

## Requirements
1. **Base manifests** (in `starter/app`)
   - Deployment named `gitops-demo` running image `ghcr.io/example/gitops-demo:latest` on port 8080.
   - Add env var `APP_ENV` (default `dev`).
   - Expose via ClusterIP Service `gitops-demo` on port 8080.
2. **Kustomize overlays** (in `starter/overlays`)
   - `dev`: 1 replica, image tag `dev`, env `LOG_LEVEL=debug`.
   - `prod`: 3 replicas, image tag `stable`, CPU/Memory limits, env `LOG_LEVEL=info`.
   - Both overlays should reuse the base and patch only differences.
3. **ArgoCD Application** (in `starter/argocd`)
   - Application named `gitops-demo` pointing to the repo path for the `prod` overlay.
   - Automate sync with `selfHeal` and `prune` enabled.
   - Target namespace `gitops-demo` (create via Argo if missing).
4. **Docs**
   - Add a short `starter/README.md` explaining how to apply Kustomize overlays locally and how ArgoCD will promote changes.

### Deliverables
- Updated manifests in `starter/app` and overlays under `starter/overlays/*`.
- ArgoCD Application manifest in `starter/argocd/application.yaml`.
- Brief README with local apply instructions.
