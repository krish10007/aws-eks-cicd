# aws-eks-cicd

Containerized FastAPI app deployed to AWS EKS with:
- Horizontal Pod Autoscaling (HPA)
- ALB Ingress Controller with SSL termination
- Helm charts for dev/prod environment management
- GitHub Actions CI/CD pipeline (push → ECR → EKS in <3 min)
- Full Terraform IaC — zero click-ops
- Verified autoscaling under k6 load test

> Architecture diagram, benchmark numbers, and load test results coming after build completion.

## Stack
Python 3.11 · FastAPI · Docker · AWS EKS · AWS ECR · Kubernetes · Helm · HPA · ALB · ACM · Secrets Manager · Terraform · GitHub Actions (OIDC) · k6 · CloudWatch