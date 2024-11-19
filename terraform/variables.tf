variable "bearer_token" {
  type      = string
  sensitive = true
}

variable "server_url" {
  type      = string
  sensitive = false
}

variable "kube_config" {
  type      = string
  sensitive = true
  default   = "~/.kube/config"
}

variable "kube_context" {
  type      = string
  sensitive = false
  default   = "default"
}

variable "eopa_license_key" {
  type      = string
  sensitive = true
}
