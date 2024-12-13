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
}

module "us_accounts" {
   source = "./services"

  name             = "us-accounts"
  namespace        = kubernetes_namespace.accounts.metadata[0].name
  image            = "ghcr.io/kroekle/accounts-demo-app/accounts-service:latest"
  env_vars         = {
   US_CONTROLLER = "true"
   PORT          = "80"
  }
  kube_config      = var.kube_config
  kube_context     = var.kube_context
  eopa_license_key = var.eopa_license_key
  secret_name      = module.us_system.secret_name
  path             = "/v1/u/accounts"
  opa_path         = "/usopa"
}

module "global_accounts" {
   source = "./services"

  name             = "global-accounts"
  namespace        = kubernetes_namespace.accounts.metadata[0].name
  image            = "ghcr.io/kroekle/accounts-demo-app/accounts-service:latest"
  env_vars         = {
   US_CONTROLLER = "false"
   PORT          = "80"
   JUNK          = ""
  }
  kube_config      = var.kube_config
  kube_context     = var.kube_context
  eopa_license_key = var.eopa_license_key
  secret_name      = module.global_system.secret_name
  path             = "/v1/g/accounts"
  opa_path         = "/gopa"
}

module "accounts-ui" {
  source = "./services"

  name             = "accounts-ui"
  namespace        = kubernetes_namespace.accounts.metadata[0].name
  image            = "ghcr.io/kroekle/accounts-demo-app/accounts-ui:latest"
  skip_istio       = true
  kube_config      = var.kube_config
  kube_context     = var.kube_context
  eopa_license_key = var.eopa_license_key
  secret_name      = "none"
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

  kube_config       = var.kube_config
  kube_context      = var.kube_context
  namespace         = kubernetes_namespace.accounts.metadata[0].name
  bearer_token      = var.bearer_token
  server_url        = var.server_url
  us_system_id      = module.us_system.system_id
  global_system_id  = module.global_system.system_id
}