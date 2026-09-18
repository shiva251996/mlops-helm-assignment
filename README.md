# MLOps Helm Chart – Multi-Environment ML API Deployment

## Problem
Earlier, the team was copying the same Kubernetes YAML files for Dev, Staging and Production. This created a lot of duplicate work and sometimes the configurations became inconsistent.

## Solution
We created one generic Helm chart. Now we just maintain different values files for each environment (`values-dev.yaml`, `values-staging.yaml`, `values-prod.yaml`).

ML engineers only need to change a few values and run a single helm command.

---

## Project Structure

```
mlops-helm-assignment/
├── charts/ml-api/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-dev.yaml
│   ├── values-staging.yaml
│   ├── values-prod.yaml
│   ├── templates/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── hpa.yaml
│   │   └── ...
│   └── tests/
├── .github/workflows/
│   └── helm-ci-cd.yaml
├── terraform/
│   └── main.tf
└── README.md
```

---

## How to Run Locally (Minikube)

1. Start Minikube:
```bash
minikube start --driver=docker
```

2. Deploy to Dev:
```bash
helm upgrade --install ml-api-dev ./charts/ml-api \
  -f ./charts/ml-api/values-dev.yaml \
  -n ml-dev --create-namespace
```

3. Check pods:
```bash
kubectl get pods -n ml-dev
```

4. Access the API:
```bash
kubectl port-forward svc/ml-api-dev 8080:80 -n ml-dev
```

Then open another terminal and run:
```bash
curl.exe http://localhost:8080
```

---

## Helm Test
```bash
helm test ml-api-dev -n ml-dev
```

---

## CI/CD Pipeline

The GitHub Actions workflow does the following:

- Lints the Helm chart
- Validates Dev, Staging and Production templates **in parallel** using matrix strategy
- Packages the chart
- Uploads the packaged chart as an artifact (simulating publish to a private registry)

This helps catch issues early before deploying.

---

## Terraform (IAC Example)

A simple Terraform example is available in `terraform/main.tf`.  
It shows how the same Helm chart can be deployed by just changing the environment variable.

---

## Secrets Handling

We do not store any secrets in Git.

Recommended ways:
- External Secrets Operator
- Sealed Secrets
- HashiCorp Vault

The chart only uses secret names. Actual secret values are injected at runtime.

---

## Autoscaling

Horizontal Pod Autoscaler (HPA) is included.

- Dev → Autoscaling is disabled
- Staging & Production → Autoscaling is enabled with different min/max values

---

## Version Control

- Chart version is managed in `Chart.yaml`
- We use Git for source control
- GitHub Actions runs on every push to main

---

## Future Improvements

- GitOps with ArgoCD
- Canary deployments using Flagger
- Model versioning with MLflow
- Better monitoring and alerts
