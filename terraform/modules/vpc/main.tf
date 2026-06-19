module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  # NAT Gateway lets pods in private subnets reach the internet
  # (e.g. to pull images, call external APIs) without being publicly exposed
  enable_nat_gateway   = true
  single_nat_gateway   = true  # one NAT GW is enough for dev; prod would use one per AZ
  enable_dns_hostnames = true
  enable_dns_support   = true

  # These tags are REQUIRED by the AWS Load Balancer Controller
  # It looks for subnets with these tags to know where to create ALBs
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Environment                                       = var.environment
    ManagedBy                                         = "terraform"
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
  }
}