# Namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Prometheus and Grafana
resource "helm_release" "prometheus_stack" {
  name       = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    file("${path.module}/values/prometheus-values.yaml")
  ]

  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "7d" # Reduce retention for cost savings
  }

  set {
    name  = "prometheus.prometheusSpec.resources.requests.cpu"
    value = "200m"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.requests.memory"
    value = "512Mi"
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 30
  kms_key_id        = var.kms_key_arn

  tags = var.tags
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cluster_health" {
  for_each = {
    cpu    = { metric = "CPUUtilization", threshold = 80 }
    memory = { metric = "MemoryUtilization", threshold = 80 }
  }

  alarm_name          = "${var.environment}-cluster-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = each.value.metric
  namespace           = "AWS/EKS"
  period              = "300"
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = var.tags
}
