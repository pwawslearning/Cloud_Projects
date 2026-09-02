variable "security_groups_config" {
  description = "Map of security groups with their ingress/egress rules"

  type = map(object({
    name        = string
    description = string
    tags        = optional(map(string), {})

    ingress_rules = optional(map(object({
      description    = string
      from_port      = number
      to_port        = number
      ip_protocol    = string
      cidr_ipv4      = optional(string)
      cidr_ipv6      = optional(string)
      security_group = optional(string)
      prefix_list_id = optional(string)
    })), {})

    egress_rules = optional(map(object({
      description    = string
      from_port      = optional(number)
      to_port        = optional(number)
      ip_protocol    = string
      cidr_ipv4      = optional(string)
      cidr_ipv6      = optional(string)
      security_group = optional(string)
      prefix_list_id = optional(string)
    })), {})
  }))
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}