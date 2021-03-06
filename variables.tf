# Generic
variable "owner" {
  description = "Prefix for all tags and names"
  type        = string
  default     = "fj"
}

variable "bg" {
  type    = string
  default = "green"
}

# Instances
variable "cloud_pub" {
  description = "SSH key name"
  type        = string
  default     = "default"
}

variable "rel_seq" {
  type    = string
  # default = 504
  default = 0
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

# DNS
variable "dns_record_name" {
  description = "DNS A Record alias prefix for the Load Balancer"
  type        = string
  default     = "flamarion-es"
}

variable "redis_port" {
  description = "Redis Port"
  type        = number
  default     = 6379
}
