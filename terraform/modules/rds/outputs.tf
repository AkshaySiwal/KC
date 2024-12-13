output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.rds.db_instance_address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.rds.db_instance_arn
}

output "db_instance_name" {
  description = "The database name"
  value       = var.database_name
}

output "db_subnet_group_name" {
  description = "The db subnet group name"
  value       = aws_db_subnet_group.this.name
}

output "db_security_group_id" {
  description = "The security group ID"
  value       = aws_security_group.rds.id
}
