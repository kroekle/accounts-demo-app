
output "us_system_id" {
  value = module.us_system.system_id
}

output "global_system_id" {
  value = module.global_system.system_id
}

output "stack_id" {
  value = styra_stack.accounts_stack.id
}

