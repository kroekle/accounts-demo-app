
output "us_system_id" {
  value = module.us_system.system_id
}

output "global_system_id" {
  value = module.global_system.system_id
}

output "stack_id" {
  value = styra_stack.accounts_stack.id
}

/*
output "us_status" {
  value = module.data_sources.us_datasource_status
}

output "global_status" {
  value = module.data_sources.global_datasource_status
}
*/