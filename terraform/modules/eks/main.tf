module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-cluster"
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Makes the Kubernetes API server reachable from your laptop via kubectl
  cluster_endpoint_public_access = true

  # EKS managed node group — AWS handles node provisioning and updates
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 5      # HPA can scale pods; cluster autoscaler can scale nodes
      desired_size   = 2      # start with 2 nodes for resilience

      labels = {
        Environment = var.environment
      }
    }
  }

  # Gives your AWS user admin access to the cluster automatically
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}