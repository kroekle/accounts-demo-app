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

resource "styra_policy" "openapi_transform_policy" {
  policy                     = "systems/${styra_system.system.id}/transform/openapi"
  modules = {
    "openapi.rego" = <<-EOT
      package transform.openapi

      method_with_resources[upper(method)] := r {
        
        methods[method]
        r := {replace_path_templates_with_globs(r).path:{"tags":tags,"roles":roles} | tags := get_tags(input.paths[r][m]); m == method; roles := get_roles(input.paths[r][m])}
      }

      methods[m] {
        input.paths[_][m]
      }

      get_tags(entry) = {x |
            x := entry.tags[_]
      }

      # openapi supports different roles for different authentication schemes: OAuth and OpenId
      # Here we just union them all, since our input schema does not tell us what scheme to use.
      # In all likelihood they are the same roles, since the authentication scheme should not
      # be changing the required roles anyway.  Of course, your mileage may vary.
      # https://swagger.io/docs/specification/authentication/
      # null roles denotes the roles list is missing, implying a public API
      get_roles(entry) = {x |
            some authn
              x := entry.security[_][authn][_]
      }

      # replace_path_templates_with_globs rewrites openapi path templates to globs
      # e.g., /shelves/{shelf}/books/{book} to /shelves/*/books/*
      # and returns a map with position indices mapping to variable names
      # e.g., {1: shelf, 3: book} for above
      replace_path_templates_with_globs(path) = {"path": rewritten_path, "variables": vars} {
        segments := split(path, "/")
        rewritten_segments := [rewritten |
          original := segments[_]
          rewritten := replace_segment_with_globs(original).segment
        ]

        vars := {position: var_name |
          original := segments[position]
          var_name := replace_segment_with_globs(original).variable
        }

        rewritten_path := concat("/", rewritten_segments)
      }

      replace_segment_with_globs(segment) = {"segment": rewritten_segment, "variable": variable} {
        startswith(segment, "{")
        endswith(segment, "}")
        rewritten_segment := "*"
        variable := trim_prefix(trim_suffix(segment, "}"), "{")
      } else = {"segment": segment} {
        true
      }
    EOT
  }
}

resource "styra_policy" "accounts_transform_policy" {
  policy                     = "systems/${styra_system.system.id}/transform/accounts"
  modules = {
    "accounts.rego" = <<-EOT
      package transform.accounts
      import rego.v1

      main[account] := {"region": region, "manager": manager} if {
        account := input[i].id
        region := input[i].region
        manager := input[i].manager.id
      }    

      main["graph"] contains [manager,"owns",account] if {
        account := input[idx].id
        manager := input[idx].manager.id
      }

      # all of our users should have view access
      viewers := ["1","2","4","5"]  # you would normally want to get this from data
      main["graph"] contains [viewer,"views",account] if {
        viewer := viewers[_]
        account := input[_].id
      }

      us_transfer_users := ["1", "2"]
      us_regions := ["EAST","WEST","NORTH","SOUTH"]
      main["graph"] contains [viewer,"txfr",account] if {
        viewer := us_transfer_users[_]
        input[x].region in us_regions
        account := input[x].id
      }

      global_transfer_users := ["1", "5"]
      main["graph"] contains [viewer,"txfr",account] if {
        viewer := global_transfer_users[_]
        not input[x].region in us_regions
        account := input[x].id
      }
    EOT
  }
}

resource "styra_policy" "ingress_policy" {
  policy                     = "systems/${styra_system.system.id}/policy/ingress"
  modules = {
    "opa.rego" = <<-EOT
      package policy.ingress
      import rego.v1

      #allow check requests directly to OPA sidecar
      allow if {
        input.attributes.request.http.method == "POST"
        input.parsed_path = ["v1", "data","policy","ui",_]
      }
      allow if {
        input.attributes.request.http.method == "POST"
        input.parsed_path = ["v1", "batch", "data","policy","ui",_]
      }

      # this is allowing DAS to call into the service, this should acourse be changed to a real idenity
      allow if {
        input.attributes.request.http.headers.authorization == "Bearer apitoken"
        input.attributes.request.http.method == "GET"
        input.parsed_path = ["v1", _, "accounts"]
      }

      #not really an opa rule, but...
      allow if {
        input.attributes.request.http.method == "GET"
        input.parsed_path = ["v3", "api-docs"]
      }

      #these are to be able to switch on authz type

      #RBAC will be the default if no others are set
      RBAC if {
        not ABAC
        not PBAC
        not ReBAC
      }

      ABAC if {
        input.attributes.request.http.headers["authz-type"] == "ABAC"
      }

      ReBAC if {
        input.attributes.request.http.headers["authz-type"] == "ReBAC"
      }

      PBAC if {
        input.attributes.request.http.headers["authz-type"] == "PBAC"
      }
    EOT
    "rules.rego" = <<-EOT
        package policy.ingress
        import rego.v1

        # Add policy/rules to allow or deny ingress traffic
 
        default allow = false
 

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
    "1-rbac.rego" = <<-EOT
      package policy.ingress
      import rego.v1

      allow if {
        RBAC # this is only needed because the demo can switch between types
        api_roles := data.openapi[input.attributes.request.http.method][glob_path].roles
        glob.match(glob_path, ["/"], split(input.attributes.request.http.path, "?")[0])
        claims.roles[_] in api_roles
      }
    EOT
    "2-abac.rego" = <<-EOT
        package policy.ingress
        import rego.v1

        allow if {
          ABAC # this is only needed because the demo can switch between types
          department_match
          input.attributes.request.http.method == "GET" # viewing account
          claims.level > 0
        }

        allow if {
          ABAC # this is only needed because the demo can switch between types
          dept_and_territory_match
          account_transfers
          claims.level > 2
        }

        allow if {
          ABAC # this is only needed because the demo can switch between types
          dept_and_territory_match
          input.attributes.request.http.method in ["PATCH", "DELETE"]  # close/reactive account
          claims.level > 3  # above level 3 can work cross region
        }

        allow if {
          ABAC # this is only needed because the demo can switch between types
          dept_and_territory_match
          input.attributes.request.http.method in ["PATCH", "DELETE"]  # close/reactive account
          input.parsed_path = ["v1", _, "accounts", account_id]
          data.accounts[account_id].region in claims.homeRegions # need to be in region to close/reactive accounts (unless > level 3)
        }

        department_match if {
          tags := data.openapi[input.attributes.request.http.method][glob_path].tags
          glob.match(glob_path, ["/"], split(input.attributes.request.http.path, "?")[0])
          claims.department in tags
        }

        dept_and_territory_match if {
          tags := data.openapi[input.attributes.request.http.method][glob_path].tags
          glob.match(glob_path, ["/"], split(input.attributes.request.http.path, "?")[0])
          claims.territories[_] in tags
          claims.department in tags
        }

        account_transfers if {
          input.attributes.request.http.method == "POST"
          "transfer" in data.openapi[input.attributes.request.http.method][glob_path].tags
          glob.match(glob_path, ["/"], split(input.attributes.request.http.path, "?")[0])
        }
    EOT
    "3-rebac.rego" = <<-EOT
      package policy.ingress
      import rego.v1

      #much of the ReBAC polices end up being in how the data model is created, in this case in the transfomrm/accounts/accounts.rego


      # this would likely be pulled from a different source
      backups contains ["1", "backsup", "2"]
      backups contains ["1", "backsup", "5"]
      backups contains ["2", "backsup", "1"]
      backups contains ["2", "backsup", "4"]

      working_account := account if {
        input.parsed_path = ["v1", _, "accounts", account]
      }

      working_account := account if {
        input.parsed_path = ["v1", _, "accounts","txfr", account, _, _]
      }

      employee_id := claims.employeeNumber

      allow if {
        ReBAC
        input.attributes.request.http.method == "GET"
        input.parsed_path = ["v1", _, "accounts"]
        viewable_accounts := [a| data.accounts.graph[_] = [employee_id,"views",a]]
        count(viewable_accounts) > 0
      }

      allow if {
        ReBAC
        input.attributes.request.http.method == "GET"
        data.accounts.graph[_] = [employee_id,"views",working_account]
      }

      allow if {
        ReBAC
        input.attributes.request.http.method in ["DELETE", "PATCH"]
        data.accounts.graph[_] = [employee_id,"owns",working_account]
      }
      allow if {
        ReBAC
        input.attributes.request.http.method in ["DELETE", "PATCH"]
        backups[[employee_id,"backsup",other_employee]]
        data.accounts.graph[_] = [other_employee,"owns",working_account]
      }

      allow if {
        ReBAC
        input.attributes.request.http.method in ["POST"]
        data.accounts.graph[_] = [employee_id,"txfr",working_account]
      }

      allow if {
        ReBAC
        input.attributes.request.http.method in ["POST"]
        backups[[employee_id,"backsup",other_employee]]
        data.accounts.graph[_] = [other_employee,"txfr",working_account]
      }
    EOT
    "4-pbac.rego" = <<-EOT
      package policy.ingress
      import rego.v1

      import data.policy.ingress.PBAC
      import data.policy.ingress.department_match # ABAC policy
      import data.policy.ingress.backups # ReBAC data

      allow if {
        PBAC # this is only needed because the demo can switch between types
        input.attributes.request.http.method == "GET"
        input.parsed_path = ["v1", _, "accounts"]
        claims.level > 0
        department_match
      }

      allow if {
        PBAC # this is only needed because the demo can switch between types
        input.attributes.request.http.method in ["DELETE", "PATCH"]
        input.parsed_path = ["v1", _, "accounts", account_id]
        data.accounts[account_id].manager == claims.employeeNumber
      }

      allow if {
        PBAC # this is only needed because the demo can switch between types
        input.attributes.request.http.method in ["DELETE", "PATCH"]
        input.parsed_path = ["v1", _, "accounts", account_id]
        backups[[claims.employeeNumber,"backsup",data.accounts[account_id].manager]]
        swiped_in
      }

      allow if {
        PBAC # this is only needed because the demo can switch between types
        input.attributes.request.http.method in ["POST"]
        input.parsed_path = ["v1", _, "accounts", "txfr", account_id, _, _]
        data.accounts[account_id].manager == claims.employeeNumber
      }
      
      allow if {
        PBAC # this is only needed because the demo can switch between types
        input.attributes.request.http.method in ["POST"]
        backups[[employee_id,"backsup",other_employee]]
        backups[[claims.employeeNumber,"backsup",data.accounts[account_id].manager]]
        during_working_hours
        claims.level > 2
      }

      during_working_hours if {
        http.send(
          {
            "method": "get", 
            "url": "http://state-svc:80/attributes/officeHours", 
            "raise_error":false, 
            "force_cache_duration_seconds": 1,
            "force_cache": true,
            "force_json_decode": true,
            "cache": true
            }).body.value
      }

      swiped_in if {
        http.send(
          {
            "method": "get", 
            "url": "http://state-svc:80/attributes/swipedIn", 
            "raise_error":false, 
            "force_cache_duration_seconds": 1,
            "force_cache": true,
            "force_json_decode": true,
            "cache": true
            }).body.value
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
