variable "kube_config" {
  type      = string
  sensitive = true
}

variable "kube_context" {
  type      = string
  sensitive = false
}

variable "name" {
  type      = string
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

variable "install_slp" {
  type      = bool
  default   = false
}

variable "slp_image_base" {
  type      = string
  default   = ""
}