output "repository_url" {
  description = "Full ECR repository URL (used in docker push and Helm values)"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ECR repository ARN (used in IAM policies)"
  value       = aws_ecr_repository.this.arn
}