# Generic
variable "owner" {
  description = "Prefix for all tags and names"
  type        = string
  default     = "fj"
}

variable "bg" {
  type = string
  default = "blue"
}

# Instances
variable "cloud_pub" {
  description = "SSH key name"
  type        = string
  default     = "default"
}

# TFE
variable "admin_password" {
  type    = string
  default = "SuperS3cret"
}

variable "rel_seq" {
  type    = string
  default = 501
}

variable "lic_ch_id" {
  type    = string
  default = "f2512d8ea712baead124b22a5b31aeaf"
}

variable "tfe_ha" {
  type    = number
  default = 1
}

# Load Balancer

variable "https_port" {
  description = "HTTPS Port"
  type        = number
  default     = 443
}

variable "https_proto" {
  description = "HTTPS Protocol"
  type        = string
  default     = "HTTPS"
}

variable "replicated_port" {
  description = "Replicated Port"
  type        = number
  default     = 8800
}

variable "replicated_proto" {
  description = "Replicated HTTP Protocol"
  type        = string
  default     = "HTTPS"
}

# DNS
variable "dns_record_name" {
  description = "DNS A Record alias prefix for the Load Balancer"
  type        = string
  default     = "flamarion-es"
}

