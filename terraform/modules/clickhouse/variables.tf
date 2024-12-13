
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}

variable "clickhouse_username" {
  description = "ClickHouse admin username"
  type        = string
  default     = "admin"
}

variable "clickhouse_password" {
  description = "ClickHouse admin password"
  type        = string
  sensitive   = true
}

variable "chart_version" {
  description = "ClickHouse Helm chart version"
  type        = string
  default     = "4.0.2"
}
