variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer to protect"
  type        = string
}

variable "block_ip_addresses" {
  description = "IPv4 addresses/CIDRs to block"
  type        = list(string)
  default     = []
}

variable "enable_geo_block" {
  description = "Enable geographic blocking rule"
  type        = bool
  default     = false
}

variable "geo_block_countries" {
  description = "ISO 3166-1 alpha-2 country codes to block"
  type        = list(string)
  default     = []
}