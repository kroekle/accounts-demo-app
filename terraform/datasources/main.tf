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
}

resource "null_resource" "us_accounts_dsx" {
  provisioner "local-exec" {
    command = "curl -X PUT -H 'Authorization: Bearer ${var.bearer_token}' ${local.us_url} -d '${local.us_request_body}'"
  }
}

resource "null_resource" "global_accounts_ds" {
  provisioner "local-exec" {
    command = "curl -X PUT -H 'Authorization: Bearer ${var.bearer_token}' ${local.global_url} -d '${local.global_request_body}'"
  }
}

/*
data "http" "us_accounts_ds" {
    url                  = "${var.server_url}/v1/datasources/systems/${var.us_system_id}/openapi"
    request_headers = {
        Authorization = "Bearer ${var.bearer_token}"
    }
    method               = "POST"
    request_body         = jsonencode({
        category             = "http"
        url                  = "http://relay-server:8080/v1/relay/apidocs/us-accounts/v3/api-docs"
        method               = "get"
        body                 = ""
        polling_interval     = "1h"
        on_premises          = false
        skip_tls_verification = false
    })
}

data "http" "global_accounts_ds" {
    url                  = "${var.server_url}/v1/datasources/systems/${var.global_system_id}/openapi"
    request_headers = {
        Authorization = "Bearer ${var.bearer_token}"
    }
    method               = "POST"
    request_body         = jsonencode({
        category             = "http"
        url                  = "http://relay-server:8080/v1/relay/apidocs/global-accounts/v3/api-docs"
        method               = "get"
        body                 = ""
        polling_interval     = "1h"
        on_premises          = true
        skip_tls_verification = false
    })
}
*/
resource "kubernetes_config_map" "datasources_agent_config" {
    metadata {
        name = "datasources-agent-config"
        namespace = var.namespace
    }

    data = {
        "conf.yaml" = <<-EOT
            datasources:
                systems/${var.us_system_id}/openapi:
                systems/${var.global_system_id}/openapi:
        EOT
    }
}

# TODO: replace bearer_token with newly created token for data agent
resource "kubernetes_secret" "styra_access" {
    metadata {
        name = "styra-access"
        namespace = var.namespace
    }

    type = "Opaque"

    data = {
        token = var.bearer_token
        //token = "5LZi2garJxqKYn7lFkyGo6cLLN-NB31D0f-mMV8DbpErYYF8Q67vg4wNOpMzGfv8Mq460BVxxwZsDGdH0cH3TPGfKxYe"
    }
}


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
                    image = "styra/relay-client:latest"
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
/*
                    resources {
                        limits {
                            cpu    = "500m"
                            memory = "512Mi"
                        }
                        requests {
                            cpu    = "100m"
                            memory = "128Mi"
                        }
                    }
*/
                }

                security_context {
                    run_as_non_root = true
                    run_as_user     = 1000
                }
            }
        }
    }
}


