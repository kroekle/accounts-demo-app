provider "kubernetes" {
  config_path = var.kube_config
  config_context = var.kube_context == "default" ? null : var.kube_context
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.name
      }
    }
    template {
      metadata {
        labels = {
          app = var.name
        }
        annotations = var.skip_istio ? {
          "sidecar.istio.io/inject" = "false"
        } : {}
      }
      spec {
        container {
          name  = var.name
          image = var.image
          dynamic "env" {
              for_each = var.env_vars
              content {
              name  = env.key
              value = env.value
              }
            }
        }
        dynamic "container" {
          for_each = var.skip_istio ? [] : [1]
          content {
            name  = "opa"
            image = "ghcr.io/styrainc/enterprise-opa:1.29.0"
            args = [
              "run",
              "--server",
              "--config-file=/config/config.yaml",
              "--addr=http://0.0.0.0:8181",
              "--diagnostic-addr=0.0.0.0:8282",
              "--authorization=basic"
            ]
            readiness_probe {
              initial_delay_seconds = 20
              http_get {
                path   = "/health"
                scheme = "HTTP"
                port   = 8282
              }
            }
            security_context {
              run_as_user = 1111
            }
            resources {
              requests = {
                cpu    = "100m"
                memory = "128Mi"
              }
              limits = {
                cpu    = "500m"
                memory = "256Mi"
              }
            }
            volume_mount {
              name       = "opa-config"
              mount_path = "/config"
            }
            env {
              name  = "EOPA_LICENSE_KEY"
              value = var.eopa_license_key
            }
            env {
              name  = "OPA_LOG_TIMESTAMP_FORMAT"
              value = "2006-01-02T15:04:05.999999999Z07:00"
            }
            port {
              container_port = 8181
            }
          }
        }
        volume {
          name = "opa-config"
          secret {
            secret_name = var.secret_name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    selector = {
      app = var.name
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
    port {
      name        = "opa"
      port        = 8181
      target_port = 8181
    }
  }
}

resource "kubernetes_manifest" "http_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = {
      parentRefs = [
        {
          name = "gateway"
        }
      ]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = var.path
              }
            }
          ]
          backendRefs = [
            {
              name = var.name
              port = 80
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "opa_http_route" {
  count = var.opa_path != "NONE" ? 1 : 0
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "opa-${var.name}"
      namespace = var.namespace
    }
    spec = {
      parentRefs = [
        {
          name = "gateway"
        }
      ]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = var.opa_path
              }
            }
          ]
          filters = [
            {
              type = "URLRewrite"
              urlRewrite = {
                path = {
                  type = "ReplacePrefixMatch"
                  replacePrefixMatch = "/"
                }
              }
            }
          ]
          backendRefs = [
            {
              name = var.name
              port = 8181
            }
          ]
        }
      ]
    }
  }
}

/*
resource "kubernetes_manifest" "opa_http_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "opa_${var.name}"
      namespace = var.namespace
    }
    spec = {
      parentRefs = [
        {
          name = "gateway"
        }
      ]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = var.opa_path
              }
            }
          ]
          filters = [
            {
              type = "URLRewrite"
              urlRewrite = {
                path = {
                  type = "ReplacePrefixMatch"
                  replacePrefixMatch = "/"
                }
              }
            }
          ]
          backendRefs = [
            {
              name = var.name
              port = 8181
            }
          ]
        }
      ]
    }
  }
}
*/
/*
resource "kubernetes_manifest" "ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = {
      ingressClassName = "istio"
      rules = [
        {
          host = "accounts.norsebank.com"
          http = {
            paths = [
              {
                path     = "/json"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = var.name
                    port = {
                      number = 80
                    }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
}
*/

/*
resource "kubernetes_ingress" "ingress" {
  metadata {
    name      = var.name
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "istio"
    }
  }

  spec {
    rule {
      host = "accounts.norsebank.com"
      http {
        path {
          path = var.path
          backend {
            service_name = var.name
            service_port = 80
          }
        }
      }
    }
  }
}
*/
