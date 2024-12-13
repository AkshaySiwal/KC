# Create DB subnet group
resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.database_subnet_ids
  tags       = var.tags
}

# Create security group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.environment}-rds-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  tags = var.tags
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.0"

  identifier = "${var.environment}-mysql"

  engine               = "mysql"
  engine_version       = "8.0.28"
  family               = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = "db.t3.large"

  allocated_storage     = 100
  max_allocated_storage = 200

  db_name  = var.database_name
  username = var.database_username
  port     = 3306

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  backup_retention_period = 7
  skip_final_snapshot     = false
  deletion_protection     = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60

  auto_minor_version_upgrade = true

  tags = var.tags
}
