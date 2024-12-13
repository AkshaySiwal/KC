variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "me-south-1"
}

variable "dr_region" {
  description = "DR AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for primary VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dr_vpc_cidr" {
  description = "CIDR block for DR VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "primary_azs" {
  description = "Availability zones in primary region"
  type        = list(string)
  default     = ["me-south-1a", "me-south-1b", "me-south-1c"]
}

variable "dr_azs" {
  description = "Availability zones in DR region"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "knowledgecity"
}

variable "database_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "admin"
  sensitive   = true
}



variable "clickhouse_password" {
  description = "Username for the clickhouse user"
  type        = string
  default     = "admin"
  sensitive   = true
}
