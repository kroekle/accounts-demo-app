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

locals {
  us_url            = "${var.server_url}/v1/datasources/systems/${var.us_system_id}/openapi"
  us_request_body   = jsonencode({
    category                = "http"
    url                     = "http://relay-server:8080/v1/relay/apidocs/us-accounts.accounts-demo/v3/api-docs"
    method                  = "get"
    body                    = ""
    polling_interval        = "1h"
    on_premises             = false
    skip_tls_verification   = false
    policy_filter           = "systems/${var.us_system_id}/transform/openapi/openapi.rego"
    policy_query            = "data.transform.openapi.method_with_resources"
  })
  global_url                = "${var.server_url}/v1/datasources/systems/${var.global_system_id}/openapi"
  global_request_body       = jsonencode({
    category                = "http"
    url                     = "http://relay-server:8080/v1/relay/apidocs/global-accounts/v3/api-docs"
    method                  = "get"
    body                    = ""
    polling_interval        = "1h"
    on_premises             = false
    skip_tls_verification   = false
    policy_filter           = "systems/${var.global_system_id}/transform/openapi/openapi.rego"
    policy_query            = "data.transform.openapi.method_with_resources"
  })
  us_accounts_url            = "${var.server_url}/v1/datasources/systems/${var.us_system_id}/accounts"
  us_accounts_request_body   = jsonencode({
    category                = "http"
    url                     = "http://relay-server:8080/v1/relay/apidocs/us-accounts.accounts-demo/v1/u/accounts"
    method                  = "get"
    body                    = ""
    headers = [{
        name = "authorization",
        value = "Bearer apitoken"}] 
    polling_interval        = "24h"
    on_premises             = false
    skip_tls_verification   = false
    policy_filter           = "systems/${var.us_system_id}/transform/accounts/accounts.rego"
    policy_query            = "data.transform.accounts.main"
  })
  global_accounts_url                = "${var.server_url}/v1/datasources/systems/${var.global_system_id}/accounts"
  global_accounts_request_body       = jsonencode({
    category                = "http"
    url                     = "http://relay-server:8080/v1/relay/apidocs/global-accounts/v1/g/accounts"
    method                  = "get"
    body                    = ""
    headers = [{
        name = "authorization",
        value = "Bearer apitoken"}] 
    polling_interval        = "24h"
    on_premises             = false
    skip_tls_verification   = false
    policy_filter           = "systems/${var.global_system_id}/transform/accounts/accounts.rego"
    policy_query            = "data.transform.accounts.main"
  })

}

# TODO: replace bearer_token with newly created token for relay client
resource "kubernetes_deployment" "relay_client" {
    metadata {
        name      = "relay-client"
        namespace = var.namespace
    }

    spec {
        replicas = 1

        selector {
            match_labels = {
                app = "relay-client"
            }
        }

        template {
            metadata {
                annotations = {
                    "sidecar.istio.io/inject" = "false"
                }
                labels = {
                    app = "relay-client"
                }
            }

            spec {
                container {
                    name  = "relay-client"
                    image = "${var.relay_base_image_location}/relay-client:latest"
                    image_pull_policy = "Always"
                    args  = [
                        "--base-url=http:/",
                        "--server-url=wss://${replace(var.server_url, "https://", "")}/v1/relay/register",
                        "--client-key=apidocs",
                        "--styra-token=${var.bearer_token}"
                    ]

                    liveness_probe {
                        http_get {
                            path = "/v1/system/alive"
                            port = 8080
                            scheme = "HTTP"
                        }
                        initial_delay_seconds = 10
                        period_seconds        = 10
                        timeout_seconds       = 1
                        success_threshold     = 1
                        failure_threshold     = 3
                    }

                    readiness_probe {
                        http_get {
                            path = "/v1/system/ready"
                            port = 8080
                            scheme = "HTTP"
                        }
                        initial_delay_seconds = 10
                        period_seconds        = 5
                        timeout_seconds       = 1
                        success_threshold     = 1
                        failure_threshold     = 3
                    }

                }

                security_context {
                    run_as_non_root = true
                    run_as_user     = 1000
                }
            }
        }
    }
}

resource "null_resource" "delay" {
    provisioner "local-exec" {
        command = "sleep 60"
    }
}

resource "null_resource" "us_accounts_openapi_ds" {
    depends_on = [null_resource.delay]
    provisioner "local-exec" {
        command = "curl -X PUT -H 'Authorization: Bearer ${var.bearer_token}' ${local.us_url} -d '${local.us_request_body}'"
    }
}

resource "null_resource" "global_accounts_openapi_ds" {
    depends_on = [null_resource.delay]
    provisioner "local-exec" {
        command = "curl -X PUT -H 'Authorization: Bearer ${var.bearer_token}' ${local.global_url} -d '${local.global_request_body}'"
    }
}

resource "null_resource" "us_accounts_accounts_ds" {
    depends_on = [null_resource.delay]
    provisioner "local-exec" {
        command = "curl -X PUT -H 'Authorization: Bearer ${var.bearer_token}' ${local.us_accounts_url} -d '${local.us_accounts_request_body}'"
    }
}

resource "null_resource" "global_accounts_accounts_ds" {
    depends_on = [null_resource.delay]
    provisioner "local-exec" {
        command = "curl -X PUT -H 'Authorization: Bearer ${var.bearer_token}' ${local.global_accounts_url} -d '${local.global_accounts_request_body}'"
    }
}
