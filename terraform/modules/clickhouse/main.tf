resource "kubernetes_namespace" "clickhouse" {
  metadata {
    name = "clickhouse"
    labels = {
      name        = "clickhouse"
      environment = var.environment
    }
  }
}

resource "kubernetes_secret" "clickhouse_auth" {
  metadata {
    name      = "clickhouse-auth"
    namespace = kubernetes_namespace.clickhouse.metadata[0].name
  }

  data = {
    username = var.clickhouse_username
    password = var.clickhouse_password
  }

  type = "Opaque"
}

resource "helm_release" "clickhouse" {
  name       = "clickhouse"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "clickhouse"
  namespace  = kubernetes_namespace.clickhouse.metadata[0].name
  version    = var.chart_version

  values = [
    file("${path.module}/values/clickhouse-values.yaml")
  ]

  set {
    name  = "auth.username"
    value = var.clickhouse_username
  }

  set_sensitive {
    name  = "auth.password"
    value = var.clickhouse_password
  }

  set {
    name  = "persistence.size"
    value = "100Gi"
  }

  set {
    name  = "resources.requests.memory"
    value = "4Gi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "2"
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }

  set {
    name  = "metrics.serviceMonitor.enabled"
    value = "true"
  }
}
