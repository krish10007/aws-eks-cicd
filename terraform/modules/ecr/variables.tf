variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
}