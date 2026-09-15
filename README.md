# MLOps Helm Chart – Multi-Environment ML API Deployment

## Problem Statement
Previously, the team was manually copying and modifying Kubernetes manifests for every environment (Dev, Staging, Production). This led to:
- High redundancy
- Inconsistent configurations
- Time-consuming deployments
- Higher chance of human error

## Solution
A single **generic Helm chart** that can be used across all environments by simply changing the values file.

Machine Learning Engineers only need to update a few parameters in the appropriate values file (`values-dev.yaml`, `values-staging.yaml`, or `values-prod.yaml`).

---

## Project Structure

```
mlops-helm-assignment/
├── charts/ml-api/                 # Generic Helm chart
│   ├── Chart.yaml
│   ├── values.yaml                # Default values
│   ├── values-dev.yaml
│   ├── values-staging.yaml
│   ├── values-prod.yaml
│   ├── templates/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── hpa.yaml               # Horizontal Pod Autoscaler
│   │   └── ...
│   └── tests/
│       └── test-connection.yaml
├── .github/workflows/
│   └── helm-ci-cd.yaml            # CI/CD pipeline
├── terraform/
│   └── main.tf                    # IAC example
└── README.md
```

---

## Prerequisites

- Docker Desktop
- Minikube
- kubectl
- Helm
- Git

---

## How to Deploy (Local Testing with Minikube)

### 1. Start Minikube
```bash
minikube start --driver=docker
```

### 2. Deploy to Dev
```bash
helm upgrade --install ml-api-dev ./charts/ml-api \
  -f ./charts/ml-api/values-dev.yaml \
  -n ml-dev --create-namespace
```

### 3. Check Status
```bash
kubectl get pods -n ml-dev
kubectl get svc -n ml-dev
```

### 4. Make the API callable from your local machine
```bash
kubectl port-forward svc/ml-api-dev 8080:80 -n ml-dev
```

In another terminal:
```bash
curl.exe http://localhost:8080
```

You should receive a response from the sample ML API.

### Deploy to other environments
```bash
# Staging
helm upgrade --install ml-api-staging ./charts/ml-api \
  -f ./charts/ml-api/values-staging.yaml \
  -n ml-staging --create-namespace

# Production
helm upgrade --install ml-api-prod ./charts/ml-api \
  -f ./charts/ml-api/values-prod.yaml \
  -n ml-prod --create-namespace
```

---

## Helm Tests

```bash
helm test ml-api-dev -n ml-dev
```

---

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/helm-ci-cd.yaml`) automatically:

1. Lints the Helm chart
2. Validates templates for Dev, Staging, and Production
3. Packages the chart on pushes to `main`

This ensures the chart is always valid before it can be used.

---

## Infrastructure as Code (IAC)

A Terraform example is provided in `terraform/main.tf`.

It demonstrates how to deploy the same Helm chart using Terraform by only changing the `environment` variable.

---

## Secrets Management (Best Practice)

**We never store secrets in Git.**

Recommended approaches:
- External Secrets Operator + Cloud Secret Manager (AWS / Azure / GCP)
- Sealed Secrets
- HashiCorp Vault

The Helm chart only references secret names. Actual secret values are injected at runtime by the secret management tool.

---

## Autoscaling

Horizontal Pod Autoscaler (HPA) is included and can be enabled/disabled per environment through the values files.

- Dev → Autoscaling disabled
- Staging & Production → Autoscaling enabled with different min/max replicas

---

## Version Control Strategy

- Chart version is managed in `Chart.yaml` using Semantic Versioning
- Git is used for source control
- GitHub Actions packages the chart on every merge to `main`
- Recommended: Tag releases (e.g. `v0.1.0`)

---

## How MLEs Should Use This Chart

1. Update the image tag or resource limits in the appropriate values file
2. Run a single `helm upgrade --install` command
3. No need to copy or modify Kubernetes YAML files

This removes redundancy and standardizes deployments across environments.

---

## Future Improvements (Outside-the-box ideas)

- Integrate with ArgoCD for GitOps
- Add progressive delivery using Flagger
- Connect with MLflow for model versioning
- Add network policies and PodDisruptionBudgets
- Multi-cluster deployment support
```
