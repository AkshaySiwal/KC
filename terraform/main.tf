# Primary Region Resources
module "networking_primary" {
  source = "./modules/networking"
  providers = {
    aws = aws.primary
  }

  environment        = var.environment
  aws_region         = var.primary_region
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.primary_azs
  tags               = local.tags
}

module "eks_primary" {
  source = "./modules/eks"
  providers = {
    aws = aws.primary
  }

  environment        = var.environment
  dr_region          = var.dr_region
  vpc_id             = module.networking_primary.vpc_id
  private_subnet_ids = module.networking_primary.private_subnet_ids
  aws_region         = var.primary_region
  tags               = local.tags
}

module "rds_primary" {
  source = "./modules/rds"
  providers = {
    aws = aws.primary
  }

  environment                = var.environment
  vpc_id                     = module.networking_primary.vpc_id
  database_subnet_ids        = module.networking_primary.database_subnet_ids
  allowed_security_group_ids = [module.eks_primary.cluster_security_group_id]
  database_name              = var.database_name
  database_username          = var.database_username
  tags                       = local.tags
}

# DR Region Resources
module "networking_dr" {
  source = "./modules/networking"
  providers = {
    aws = aws.dr
  }

  environment        = "${var.environment}-dr"
  vpc_cidr           = var.dr_vpc_cidr
  availability_zones = var.dr_azs
  aws_region         = var.dr_region
  tags               = local.tags
}

module "dr_configuration" {
  source = "./modules/dr"
  providers = {
    aws.primary = aws.primary
    aws.dr      = aws.dr
  }

  environment             = var.environment
  dr_region               = var.dr_region
  primary_vpc_id          = module.networking_primary.vpc_id
  dr_vpc_id               = module.networking_dr.vpc_id
  primary_vpc_cidr        = var.vpc_cidr
  dr_vpc_cidr             = var.dr_vpc_cidr
  primary_route_table_ids = module.networking_primary.private_route_table_ids
  dr_route_table_ids      = module.networking_dr.private_route_table_ids
  tags                    = local.tags
}

module "s3_storage" {
  source = "./modules/s3"
  providers = {
    aws.primary = aws.primary
    aws.dr      = aws.dr
  }
  environment = var.environment
  tags        = local.tags
}

module "monitoring" {
  source = "./modules/monitoring"
  providers = {
    aws = aws.primary
  }
  environment   = var.environment
  cluster_name  = module.eks_primary.cluster_name
  kms_key_arn   = module.security.kms_key_arn
  sns_topic_arn = module.security.sns_topic_arn
  tags          = local.tags
}


module "security" {
  source = "./modules/security"
  providers = {
    aws = aws.primary
  }

  environment = var.environment
  vpc_id      = module.networking_primary.vpc_id
  tags        = local.tags
}

module "clickhouse" {
  source = "./modules/clickhouse"
  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  environment         = var.environment
  clickhouse_password = var.clickhouse_password
  tags                = local.tags

  depends_on = [module.eks_primary]
}
