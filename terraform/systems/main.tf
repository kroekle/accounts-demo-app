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

provider "styra" {
  bearer = var.bearer_token
  server_url = var.server_url
}

provider "kubernetes" {
  config_path = var.kube_config
  config_context = var.kube_context == "default" ? null : var.kube_context
}

locals {
  secret_name = "opa-conf-${styra_system.system.id}"
  system_opa_token = regex("token:\\s*([a-zA-Z0-9-_]+)", data.http.opa_config.response_body)[0]
}

resource "styra_system" "system" {
  name                     = var.name
  type                     = "template.istio:1.0"
}

/*
resource "styra_policy" "notifications_policy" {
  policy                     = "metadata/${styra_system.system.id}/notifications"
  modules = {
    "notifications.rego" = ""
  }
}
*/

resource "styra_policy" "ingress_policy" {
  policy                     = "systems/${styra_system.system.id}/policy/ingress"
  modules = {
    "rules.rego" = <<-EOT
        package policy.ingress
        import rego.v1

        # Add policy/rules to allow or deny ingress traffic

        default allow = true
        #allow check requests directly to OPA sidecar
        allow if {
          input.attributes.request.http.method == "POST"
          input.parsed_path = ["v1", "batch", "data","policy","ui",_]
        }

        # Example path based rule (will be enforced in both UI and API)
        # allow if {
        #   input.attributes.request.http.method == "DELETE"
        #   input.parsed_path = ["v1", _, "accounts", account_id]
        #   "global:admin" in claims.roles
        # }

        # Example data filtering rules (backend service uses to do SQL conditions)
        # headers["x-max-balance"] := "2000000" if {
        #   claims.sub == "5002"
        # }

        # headers["x-blocked-regions"] := "WEST" if {
        #   claims.sub == "5002"
        # }        

        claims := payload if {
          io.jwt.verify_hs256(bearer_token, "super-secret")
          [_, payload, _] := io.jwt.decode(bearer_token)
        }

        bearer_token := t if {
          v := input.attributes.request.http.headers.authorization
          startswith(v, "Bearer ")
          t := substring(v, count("Bearer "), -1)
        }    
    EOT
  }
}

resource "styra_policy" "mask_policy" {
  policy                     = "systems/${styra_system.system.id}/system/log"
  modules = {
    "mask.rego" = <<-EOT
      package system.log

      # The policy below instructs OPA to remove all data from secrets before uploading the decision
      # https://www.openpolicyagent.org/docs/latest/decision-logs/#masking-sensitive-data
      # Note: this is an example; update the policy to reflect your configuration

      # mask["/input/request/http/headers/token"]
      # 
      # mask["/input/attributes/request/http/headers/authorization"]
    EOT
  }
}

resource "styra_policy" "label_policy" {
  policy                     = "metadata/${styra_system.system.id}/labels"
  modules = {
    "labels.rego" = <<-EOT
      package metadata.${styra_system.system.id}.labels

      labels = {
        "system-type": "istio",
        "demo-application": "accounts"
      }

    EOT
  }
}

resource "styra_policy" "authz_policy" {
  policy                     = "systems/${styra_system.system.id}/system/authz"
  modules = {
    "authz.rego" = <<-EOT
      package system.authz
      import rego.v1

      # Deny access by default.
      default allow = false

      # Allow access to application data.
      allow if {
        input.path = ["v1", "data", "application", "main"]
        input.method = "POST"
      }

      # Allow access to application ui checks.
      ui_rules := ["check","always"]
      allow if {
        input.path = ["v1", "data", "policy", "ui",rule]
        input.method = "POST"
        rule in ui_rules
      }
      allow if {
        input.path = ["v1", "batch","data", "policy", "ui", rule]
        input.method = "POST"
        rule in ui_rules
      }

      # This is only used for health check in liveness and readiness probe
      allow if {
        input.path = ["health"]
        input.method = "GET"
      }

      # This is only used for prometheus metrics
      allow if {
        input.path = ["metrics"]
        input.method = "GET"
      } 
    EOT
  }
}

resource "styra_policy" "ui_policy" {
  policy                     = "systems/${styra_system.system.id}/policy/ui"
  modules = {
    "check.rego" = <<-EOT
      package policy.ui

      import data.main.main

      always := {"allowed":true}

      check := s {
        s := main with input as envoy_input
      }

      envoy_input := {
        "attributes": {
          "request": {
            "http": {
              "headers": input.options.headers,
              "method": input.options.method,
              "path": input.path
            }
          }
        },
        "parsed_path": parsed_path,
        "parsed_query": parsed_query
      }

      parsed_path := split(trim(split(input.path, "?")[0], "/"), "/")

      # this isn't totally accurate, as each query parameter can be separated by a "?"
      parsed_query := {k:v | 
                      pairs := split(split(input.path, "?")[1], "&")
                      pair := split(pairs[_], "=")
                      k := pair[0]
                      v := pair[1]
                      }
    EOT
  }
}

data "http" "opa_config" {
  url = "${var.server_url}/v1/systems/${styra_system.system.id}/assets/opaconfigdirect.yaml"
  request_headers = {
    Authorization = "Bearer ${var.bearer_token}"
  }
}

resource "kubernetes_secret" "opa-conf" {
  metadata {
    name      = local.secret_name
    namespace = var.namespace
    labels = {
      system-type  = "istio"
    }
  }

  type = "Opaque"

  data = {
    "config.yaml" = <<-EOT
      discovery:
        name: discovery
        prefix: /systems/${styra_system.system.id}
        service: styra
      labels:
        system-id: ${styra_system.system.id}
        system-type: ${styra_system.system.type}
      services:
      - credentials:
          bearer:
            token: ${local.system_opa_token}
        name: styra
        url: ${var.server_url}/v1
      - credentials:
          bearer:
            token: ${local.system_opa_token}
        name: styra-bundles
        url: ${var.server_url}/v1/bundles
    EOT
  }
}
