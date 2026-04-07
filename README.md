# k8s-terraform-local

Provision a local Kubernetes cluster with Terraform and deploy N web applications behind a shared nginx ingress controller. Each app returns its pod name and IP address. Adding a new app requires a single entry in `terraform.tfvars` — no code changes needed.

## Architecture

```
localhost:80
    │
    ▼
nginx ingress controller   (installed via Helm)
    │
    ├── /app-1   ──►  Deployment (2 replicas)  ──►  pods
    ├── /app-2   ──►  Deployment (1 replica)   ──►  pods
    ├── /app-3   ──►  Deployment (1 replica)   ──►  pods
    └── /podinfo ──►  Deployment (1 replica)   ──►  pods
```

All infrastructure is provisioned by Terraform using three reusable modules:
- `modules/cluster` — creates the kind cluster
- `modules/ingress` — installs nginx ingress via Helm
- `modules/web-app` — deploys one full app stack (Deployment + Service + Ingress); called once per app via `for_each`

---

## Prerequisites

### 1. Docker Desktop
kind runs Kubernetes nodes as Docker containers, so Docker must be running.

- Download: https://www.docker.com/products/docker-desktop
- Install and start Docker Desktop
- Verify:
  ```bash
  docker version
  ```

### 2. kind (Kubernetes in Docker)
Creates and manages the local Kubernetes cluster.

- Download: https://kind.sigs.k8s.io/docs/user/quick-start/#installation
- **Windows (PowerShell):**
  ```powershell
  winget install Kubernetes.kind
  ```
- **macOS:**
  ```bash
  brew install kind
  ```
- Verify:
  ```bash
  kind version
  ```

### 3. Terraform
Provisions all resources — the cluster, ingress controller, and web apps.

- Download: https://developer.hashicorp.com/terraform/install
- **Windows (PowerShell):**
  ```powershell
  winget install Hashicorp.Terraform
  ```
- **macOS:**
  ```bash
  brew tap hashicorp/tap && brew install hashicorp/tap/terraform
  ```
- Verify:
  ```bash
  terraform version
  ```

### 4. kubectl (optional but recommended for debugging)
Used to inspect the cluster — pods, services, ingress rules, logs.

- Download: https://kubernetes.io/docs/tasks/tools/
- **Windows (PowerShell):**
  ```powershell
  winget install Kubernetes.kubectl
  ```
- **macOS:**
  ```bash
  brew install kubectl
  ```
- Verify:
  ```bash
  kubectl version --client
  ```

---

## Getting Started

### Step 1 — Build the image, create the cluster, and load the image

The `kubernetes` and `helm` Terraform providers need a kubeconfig to initialize, which is only generated after the cluster is created. For this reason, we first create the cluster, then load the image into it before deploying everything else.

```bash
# Build the app image
docker build -t local/web-app:latest ./app

# Create the kind cluster and write the kubeconfig
cd terraform
terraform init
terraform apply -target=module.cluster -target=local_file.kubeconfig -auto-approve

# Load the image into kind (kind cannot access your local Docker registry directly)
kind load docker-image local/web-app:latest --name local-cluster
```

### Step 2 — Deploy everything

Now that the kubeconfig exists and the image is loaded, deploy the ingress controller and all web apps in one shot:

```bash
terraform apply -auto-approve
```

At the end you'll see the URLs printed as output:

```
app_urls = {
  "app-1"   = "http://localhost/app-1"
  "app-2"   = "http://localhost/app-2"
  "app-3"   = "http://localhost/app-3"
  "podinfo" = "http://localhost/podinfo"
}
```

---

## Adding or removing apps

Edit `terraform/terraform.tfvars` — no code changes required:

```hcl
apps = {
  "app-1" = { replicas = 2, path_prefix = "/app-1" }
  "app-2" = { replicas = 1, path_prefix = "/app-2" }
  "app-3" = { replicas = 1, path_prefix = "/app-3" }

  # Third-party app with a public image
  "podinfo" = {
    replicas          = 1
    path_prefix       = "/podinfo"
    image             = "ghcr.io/stefanprodan/podinfo:latest"
    container_port    = 9898
    image_pull_policy = "IfNotPresent"
  }
}
```

Then run:
```bash
terraform apply -auto-approve
```

To remove an app, delete its entry from the map and apply again.

---

## Testing

Test each endpoint with curl:

```bash
curl http://localhost/app-1
curl http://localhost/app-2
curl http://localhost/app-3
curl http://localhost/podinfo
```

Expected responses:

**app-1 / app-2 / app-3:**
```json
{"pod_ip": "10.244.0.9", "pod_name": "app-1-589f4f5677-hgnvv"}
```

**podinfo:**
```json
{
  "hostname": "podinfo-59b5d8b646-hp9gm",
  "version": "6.11.2",
  "message": "greetings from podinfo v6.11.2"
}
```

### Debugging with kubectl

```bash
export KUBECONFIG=./.kubeconfig

# Check all pods are Running
kubectl get pods

# Check ingress rules
kubectl get ingress

# Check services
kubectl get services

# View logs for an app
kubectl logs -l app=app-1
```

---

## Teardown

To destroy everything:

```bash
cd terraform
terraform destroy -auto-approve
```

This removes the kind cluster and all resources inside it.
