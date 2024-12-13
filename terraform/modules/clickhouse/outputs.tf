output "namespace" {
  description = "The Kubernetes namespace where ClickHouse is deployed"
  value       = kubernetes_namespace.clickhouse.metadata[0].name
}

output "service_name" {
  description = "The name of the ClickHouse service"
  value       = "clickhouse"
}

output "port" {
  description = "The port number for ClickHouse"
  value       = 8123
}
