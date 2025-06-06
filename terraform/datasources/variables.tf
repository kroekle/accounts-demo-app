variable "kube_config" {
  type      = string
  sensitive = true
}

variable "kube_context" {
  type      = string
  sensitive = false
}

variable "namespace" {
  type      = string
  sensitive = false
}

variable "server_url" {
  type      = string
}

variable "bearer_token" {
  type      = string
  sensitive = true
}

variable "us_system_id" {
  type      = string
  sensitive = false
}

variable "global_system_id" {
  type      = string
  sensitive = false
}

variable "datasources_depends_on" {
  type      = any
}

variable "relay_base_image_location" {
  type      = string
}