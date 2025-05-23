terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.33.0"
    }
    styra = {
      source  = "StyraInc/styra"
      version = "0.2.3"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 2.0.0"
    }
  }
}

provider "kubernetes" {
  config_path = var.kube_config
  config_context = var.kube_context == "default" ? null : var.kube_context
}

provider "styra" {
  bearer = var.bearer_token
  server_url = var.server_url
}

resource "kubernetes_namespace" "accounts" {
  metadata {
    name = "accounts-demo"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "kubernetes_manifest" "opa_ext_authz" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "EnvoyFilter"
    metadata = {
      name = "opa-ext-authz"
      namespace = kubernetes_namespace.accounts.metadata[0].name
    }
    spec = {
      configPatches = [
        {
          applyTo = "HTTP_FILTER"
          match = {
            context = "SIDECAR_INBOUND"
            listener = {
              filterChain = {
                filter = {
                  name     = "envoy.filters.network.http_connection_manager"
                  subFilter = {
                    name = "envoy.filters.http.router"
                  }
                }
              }
            }
          }
          patch = {
            operation = "INSERT_BEFORE"
            value = {
              name         = "envoy.filters.http.ext_authz"
              typed_config = {
                "@type"                   = "type.googleapis.com/envoy.extensions.filters.http.ext_authz.v3.ExtAuthz"
                transport_api_version     = "V3"
                with_request_body = {
                  max_request_bytes     = 8192
                  allow_partial_message = true
                }
                failure_mode_allow = false
                metadata_context_namespaces = ["envoy.filters.http.header_to_metadata"]
                grpc_service = {
                  google_grpc = {
                    target_uri = "127.0.0.1:9191"
                    stat_prefix = "ext_authz"
                  }
                  timeout = "0.5s"
                }
              }
            }
          }
        },
        {
          applyTo = "HTTP_FILTER"
          match = {
            context = "SIDECAR_INBOUND"
            listener = {
              filterChain = {
                filter = {
                  name     = "envoy.filters.network.http_connection_manager"
                  subFilter = {
                    name = "envoy.filters.http.ext_authz"
                  }
                }
              }
            }
          }
          patch = {
            operation = "INSERT_BEFORE"
            value = {
              name         = "envoy.filters.http.header_to_metadata"
              typed_config = {
                "@type" = "type.googleapis.com/envoy.extensions.filters.http.header_to_metadata.v3.Config"
                request_rules = [
                  {
                    header = "x-opa-authz"
                    on_header_missing = {
                      key   = "policy_type"
                      value = "ingress"
                    }
                  }
                ]
              }
            }
          }
        },
        {
          applyTo = "HTTP_FILTER"
          match = {
            context = "SIDECAR_OUTBOUND"
            listener = {
              portNumber = 80
              filterChain = {
                filter = {
                  name     = "envoy.filters.network.http_connection_manager"
                  subFilter = {
                    name = "envoy.filters.http.router"
                  }
                }
              }
            }
          }
          patch = {
            operation = "INSERT_BEFORE"
            value = {
              name         = "envoy.filters.http.ext_authz"
              typed_config = {
                "@type"                   = "type.googleapis.com/envoy.extensions.filters.http.ext_authz.v3.ExtAuthz"
                transport_api_version     = "V3"
                with_request_body = {
                  max_request_bytes     = 8192
                  allow_partial_message = true
                }
                failure_mode_allow = false
                metadata_context_namespaces = ["envoy.filters.http.header_to_metadata"]
                grpc_service = {
                  google_grpc = {
                    target_uri = "127.0.0.1:9191"
                    stat_prefix = "ext_authz"
                  }
                  timeout = "0.5s"
                }
              }
            }
          }
        },
        {
          applyTo = "HTTP_FILTER"
          match = {
            context = "SIDECAR_OUTBOUND"
            listener = {
              portNumber = 80
              filterChain = {
                filter = {
                  name     = "envoy.filters.network.http_connection_manager"
                  subFilter = {
                    name = "envoy.filters.http.ext_authz"
                  }
                }
              }
            }
          }
          patch = {
            operation = "INSERT_BEFORE"
            value = {
              name         = "envoy.filters.http.header_to_metadata"
              typed_config = {
                "@type" = "type.googleapis.com/envoy.extensions.filters.http.header_to_metadata.v3.Config"
                request_rules = [
                  {
                    header = "x-opa-authz"
                    on_header_missing = {
                      key   = "policy_type"
                      value = "egress"
                    }
                  }
                ]
              }
            }
          }
        }
      ]
    }
  }
}

resource "styra_stack" "accounts_stack" {
  name                     = "Norsebank All Accounts"
  description              = ""
  read_only                = false
  type                     = "template.istio:1.0"
}

resource "styra_policy" "stack_selector" {
  policy                     = "stacks/${styra_stack.accounts_stack.id}/selectors"
  modules = {
    "selector.rego" = <<-EOT
      package stacks.${styra_stack.accounts_stack.id}.selectors

      import data.library.v1.utils.labels.match.v1 as match

      systems[system_id] {
        include := {
          "demo-application": {
            "accounts"
          }
        }

        exclude := {}

        metadata := data.metadata[system_id]
        match.all(metadata.labels.labels, include, exclude)
      }

    EOT
  }
}

resource "styra_policy" "stack_ingress" {
  policy                     = "stacks/${styra_stack.accounts_stack.id}/policy/ingress"
  modules = {
    "rules.rego" = <<-EOT
      package stacks.${styra_stack.accounts_stack.id}.policy.ingress
      import rego.v1
      import data.policy.ingress.claims

      # 
      # headers["x-max-balance"] := "2000000" if {
      #   claims.sub == "5002"
      # }
    EOT
  }
}

resource "kubernetes_config_map" "init_sql_config" {
  metadata {
    name      = "init-sql-config"
    namespace = kubernetes_namespace.accounts.metadata[0].name
  }

  data = {
    "init.sql" = file("${path.module}/init.sql")
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.accounts.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:latest"
          env {
            name  = "POSTGRES_USER"
            value = "sa"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "sa"
          }
          env {
            name  = "POSTGRES_DB"
            value = "testdb"
          }
          volume_mount {
            name       = "init-sql-config"
            mount_path = "/docker-entrypoint-initdb.d"
          }
        }
        volume {
          name = "init-sql-config"
          config_map {
            name = kubernetes_config_map.init_sql_config.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.accounts.metadata[0].name
  }

  spec {
    selector = {
      app = "postgres"
    }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}

module "us_system" {
  source = "./systems"

  name             = "Norsebank US Accounts"
  namespace        = kubernetes_namespace.accounts.metadata[0].name
  kube_config      = var.kube_config
  kube_context     = var.kube_context
  bearer_token     = var.bearer_token
  server_url       = var.server_url
}

module "global_system" {
  source = "./systems"

  name             = "Norsebank Global Accounts"
  namespace        = kubernetes_namespace.accounts.metadata[0].name
  kube_config      = var.kube_config
  kube_context     = var.kube_context
  bearer_token     = var.bearer_token
  server_url       = var.server_url
  install_slp      = true
  slp_image_base   = var.relay_and_slp_base_image_location
}

module "us_accounts" {
  source = "./services"

  name                      = "us-accounts"
  namespace                 = kubernetes_namespace.accounts.metadata[0].name
  image                     = "${var.demo_svc_base_image_location}/accounts-service:latest"
  env_vars  = {
   US_CONTROLLER = "true"
   PORT          = "80"
  }
  other_ports = [
    {      
      name        = "sql"
      port        = 9092
      target_port = 9092
    }
  ]
  kube_config               = var.kube_config
  kube_context              = var.kube_context
  eopa_license_key          = var.eopa_license_key
  secret_name               = module.us_system.secret_name
  path                      = "/v1/u/accounts"
  opa_path                  = "/usopa"
  epoa_base_image_location  = var.epoa_base_image_location
}

module "global_accounts" {
  source = "./services"

  name                      = "global-accounts"
  namespace                 = kubernetes_namespace.accounts.metadata[0].name
  image                     = "${var.demo_svc_base_image_location}/accounts-global-service:latest"
  kube_config               = var.kube_config
  kube_context              = var.kube_context
  eopa_license_key          = var.eopa_license_key
  secret_name               = module.global_system.secret_name
  path                      = "/v1/g/accounts"
  opa_path                  = "/gopa"
  epoa_base_image_location  = var.epoa_base_image_location
}

module "accounts-ui" {
  source = "./services"

  name             = "accounts-ui"
  namespace        = kubernetes_namespace.accounts.metadata[0].name
  image            = "${var.demo_svc_base_image_location}/accounts-ui:latest"
  skip_istio       = true
  kube_config      = var.kube_config
  kube_context     = var.kube_context
  eopa_license_key = var.eopa_license_key
  secret_name      = "none"
}

module "state-svc" {
  source = "./services"

  name                      = "state-svc"
  namespace                 = kubernetes_namespace.accounts.metadata[0].name
  image                     = "${var.demo_svc_base_image_location}/state-service:latest"
  skip_istio                = true
  kube_config               = var.kube_config
  kube_context              = var.kube_context
  eopa_license_key          = var.eopa_license_key
  path                      = "/attributes"
  secret_name               = "none"
}

resource "kubernetes_manifest" "gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "gateway"
      namespace = kubernetes_namespace.accounts.metadata[0].name
    }
    spec = {
      gatewayClassName = "istio"
      listeners = [
        {
          name     = "default"
          hostname = var.application_host
          port     = 80
          protocol = "HTTP"
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        }
      ]
    }
  }
}

resource "local_file" "us_config" {
  count = var.create_local_files ? 1 : 0

  content = <<-EOT
      discovery:
        name: discovery
        prefix: /systems/${module.us_system.system_id}
        service: styra
      labels:
        system-id: ${module.us_system.system_id}
        system-type: "template.istio:1.0"
      services:
      - credentials:
          bearer:
            token: ${module.us_system.system_opa_token}
        name: styra
        url: ${var.server_url}/v1
      - credentials:
          bearer:
            token: ${module.us_system.system_opa_token}
        name: styra-bundles
        url: ${var.server_url}/v1/bundles
    EOT
  
  filename = "${path.module}/us-opa-config.yaml"
}

resource "local_file" "global_config" {
  count = var.create_local_files ? 1 : 0

  content = <<-EOT
      discovery:
        name: discovery
        prefix: /systems/${module.global_system.system_id}
        service: styra
      labels:
        system-id: ${module.global_system.system_id}
        system-type: "template.istio:1.0"
      services:
      - credentials:
          bearer:
            token: ${module.global_system.system_opa_token}
        name: styra
        url: ${var.server_url}/v1
      - credentials:
          bearer:
            token: ${module.global_system.system_opa_token}
        name: styra-bundles
        url: ${var.server_url}/v1/bundles
    EOT
  
  filename = "${path.module}/global-opa-config.yaml"
}

module "data_sources" {
  source = "./datasources"

  kube_config                   = var.kube_config
  kube_context                  = var.kube_context
  namespace                     = kubernetes_namespace.accounts.metadata[0].name
  bearer_token                  = var.bearer_token
  server_url                    = var.server_url
  us_system_id                  = module.us_system.system_id
  global_system_id              = module.global_system.system_id
  datasources_depends_on        = [module.us_accounts.service_status]
  relay_base_image_location     = var.relay_and_slp_base_image_location
}

resource "kubernetes_deployment" "load-deployment" {
  metadata {
    name      = "load"
    namespace = kubernetes_namespace.accounts.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "load"
      }
    }
    template {
      metadata {
        labels = {
          app = "load"
        }
        annotations = {
          "sidecar.istio.io/inject" = "false"
        }
      }
      spec {
        container {
          name  = "load"
          image = "${var.demo_svc_base_image_location}/accounts-load:latest"
          image_pull_policy = "Always"
        }
      }
    }
  }
}
