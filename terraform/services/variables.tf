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
  sensitive = false
}

variable "namespace" {
  type      = string
  sensitive = false
}

variable "image" {
  type      = string
  sensitive = false
}

variable "path" {
  type      = string
  sensitive = false
  default   = "/"
}

variable "opa_path" {
  type      = string
  sensitive = false
  default   = "NONE"
}

variable "eopa_license_key" {
  type      = string
  sensitive = true
}
variable "env_vars" {
  type = map(string)
  sensitive = false
  default = {}
}

variable "skip_istio" {
  type = bool
  sensitive = false
  default = false
}

variable "secret_name" {
  type = string
}

variable "epoa_base_image_location" {
  type    = string
  default = ""
}

variable "eopa_version" {
  type    = string
  default = "latest"
}