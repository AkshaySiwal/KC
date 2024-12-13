locals {
  tags = {
    Environment = var.environment
    Project     = "KnowledgeCity"
    ManagedBy   = "Terraform"
  }

  eks_addon_versions = {
    coredns    = "v1.10.1-eksbuild.2"
    kube-proxy = "v1.28.1-eksbuild.1"
    vpc-cni    = "v1.14.1-eksbuild.1"
    ebs-csi    = "v1.23.0-eksbuild.1"
  }

  common_subnet_tags = {
    "kubernetes.io/cluster/${var.environment}-eks" = "shared"
  }

  private_subnet_tags = merge(local.common_subnet_tags, {
    "kubernetes.io/role/internal-elb" = "1"
  })

  public_subnet_tags = merge(local.common_subnet_tags, {
    "kubernetes.io/role/elb" = "1"
  })
}

