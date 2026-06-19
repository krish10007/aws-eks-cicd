output "ecr_repository_url" {
  description = "ECR repository URL — use this for docker push and in Helm values"
  value       = module.ecr.repository_url
}