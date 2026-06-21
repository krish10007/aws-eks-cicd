# Containerized App on EKS with CI/CD Pipeline

Production-grade FastAPI application deployed to AWS EKS with automatic scaling, ALB ingress, and a fully automated CI/CD pipeline.

## Proof Points

| Metric | Result |
|--------|--------|
| CI/CD pipeline time (push → live) | **1 minute 19 seconds** |
| Pod autoscaling range under load | **2 → 7 pods** |
| Peak CPU utilization (HPA trigger) | **95%** |
| Total requests during load test | **82,483** |
| Request failure rate | **0.00%** |
| p95 response time under load | **202ms** |
| Throughput | **196 requests/second** |

## Architecture
Internet

│

▼

AWS ALB (internet-facing, HTTP)

│

▼

Kubernetes Ingress (aws-load-balancer-controller)

│

▼

Kubernetes Service (ClusterIP)

│

▼

FastAPI Pods (2–10 replicas, HPA-managed)

│

├── EKS Node 1 (t3.medium)

└── EKS Node 2 (t3.medium)
CI/CD: GitHub Push → GitHub Actions → ECR → helm upgrade → EKS

IaC:   Terraform (VPC, EKS, ECR, IAM)

## Stack

| Layer | Technology |
|-------|-----------|
| Application | Python 3.11, FastAPI |
| Container | Docker (multi-stage build, non-root user) |
| Registry | AWS ECR (immutable tags, lifecycle policies) |
| Orchestration | AWS EKS (Kubernetes v1.32) |
| Package Management | Helm (dev/prod values separation) |
| Autoscaling | HorizontalPodAutoscaler (CPU-based, 2–10 pods) |
| Ingress | AWS ALB via aws-load-balancer-controller |
| Networking | Custom VPC, public/private subnets, NAT Gateway |
| IaC | Terraform (modular — VPC, EKS, ECR modules) |
| Remote State | S3 + DynamoDB locking |
| CI/CD | GitHub Actions with OIDC (keyless AWS auth) |
| Load Testing | k6 (50 VUs, 7-minute staged ramp) |

## Project Structure
aws-eks-cicd/

├── app/

│   ├── main.py              # FastAPI app with health/ready/root endpoints

│   ├── requirements.txt

│   └── tests/

│       └── test_main.py     # pytest unit tests

├── helm/

│   └── fastapi-app/

│       ├── Chart.yaml

│       ├── values.yaml      # dev defaults

│       ├── values-prod.yaml # prod overrides

│       └── templates/

│           ├── deployment.yaml

│           ├── service.yaml

│           ├── hpa.yaml

│           └── ingress.yaml

├── terraform/

│   ├── main.tf

│   ├── variables.tf

│   ├── outputs.tf

│   ├── backend.tf           # S3 remote state + DynamoDB locking

│   └── modules/

│       ├── ecr/             # ECR repository + lifecycle policy

│       ├── vpc/             # VPC, subnets, NAT Gateway

│       └── eks/             # EKS cluster + managed node group

├── k6/

│   └── load-test.js         # Staged load test (2m ramp, 3m hold, 2m down)

├── .github/

│   └── workflows/

│       └── deploy.yml       # CI/CD pipeline

└── Dockerfile               # Multi-stage build, non-root user

## Key Engineering Decisions

**Immutable image tags** — Docker images are tagged with git commit SHA. The same artifact that passed tests is what gets deployed. No `latest` tag ever touches Kubernetes.

**Keyless AWS authentication** — GitHub Actions authenticates to AWS via OIDC. No AWS access keys stored anywhere. The IAM role can only be assumed by this specific GitHub repository.

**Multi-stage Dockerfile** — Builder stage installs dependencies; runtime stage copies only the installed packages. Final image has no pip, no compiler, no build cache.

**HPA with resource requests** — CPU-based autoscaling only works when pods declare resource requests. Pods request 100m CPU; HPA scales when average utilization exceeds 50%.

**Private subnets for pods** — Worker nodes and pods run in private subnets. Only the ALB is in public subnets. Pods are never directly reachable from the internet.

**Helm values separation** — `values.yaml` holds dev defaults. `values-prod.yaml` overrides only what differs in prod (replica count, resource limits). One chart, multiple environments.

## CI/CD Pipeline

Every push to `main` triggers:

1. **Test** — pytest runs against the FastAPI app
2. **Build** — Docker image built and tagged with git SHA
3. **Push** — Image pushed to ECR
4. **Deploy** — `helm upgrade --install` deploys to EKS with the new image tag
5. **Verify** — kubectl confirms rollout completed successfully

Pipeline time: **1 minute 19 seconds** from push to live.

## HPA Load Test Results

Load profile: 50 virtual users, 7-minute staged test (2m ramp up → 3m hold → 2m ramp down)
Baseline:     cpu: 2%/50%   replicas: 2

Under load:   cpu: 95%/50%  replicas: 3  (scaling triggered)

Peak:         cpu: 82%/50%  replicas: 7  (stabilized)

Post-load:    cpu: 18%/50%  replicas: 7  (scale-down pending)

k6 results: 82,483 requests · 0.00% failure rate · p95 202ms · 196 req/s

## Deployment

### Prerequisites
- AWS CLI configured
- Terraform >= 1.6
- kubectl
- Helm >= 3.0

### Provision infrastructure
```bash
cd terraform
terraform init
terraform apply
aws eks update-kubeconfig --region us-east-1 --name aws-eks-cicd-cluster
```

### Deploy application
```bash
# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=aws-eks-cicd-cluster

# Deploy app
helm install fastapi-app helm/fastapi-app/ --namespace prod --create-namespace
```

### Tear down
```bash
cd terraform && terraform destroy
```

> **Cost estimate:** ~$7–9/day while running (EKS control plane + 2x t3.medium nodes + NAT Gateway + ALB)