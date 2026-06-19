terraform {
  backend "s3" {
    bucket         = "aws-eks-cicd-tfstate-148761647179"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aws-eks-cicd-tfstate-lock"
    encrypt        = true
  }
}