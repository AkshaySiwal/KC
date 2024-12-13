output "primary_vpc_id" {
  value = module.networking_primary.vpc_id
}

output "dr_vpc_id" {
  value = module.networking_dr.vpc_id
}

output "primary_eks_cluster_endpoint" {
  value = module.eks_primary.cluster_endpoint
}

output "primary_rds_endpoint" {
  value = module.rds_primary.db_instance_endpoint
}

output "vpc_peering_connection_id" {
  value = module.dr_configuration.peering_connection_id
}

