output "system_id" {
    value = styra_system.system.id
}

output "secret_name" {
  value = var.install_slp == false ? local.secret_name : local.opa_slp_secret_name
}

output "system_opa_token" {
  value = local.system_opa_token
}