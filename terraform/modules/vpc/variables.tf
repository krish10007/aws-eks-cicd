variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  description = "IP address range for the entire VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs to spread subnets across for high availability"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}