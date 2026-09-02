variable "profile" {}
variable "region" {}

variable "project" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

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

# Instances

variable "instances" {
  description = "Map of EC2 instances to create"
  type = map(object({
    ami                     = string
    instance_type           = string
    subnet                  = string
    security_group          = string
    key_name                = optional(string)
    iam_instance_profile    = optional(string)
    associate_public_ip     = optional(bool, false)
    user_data               = optional(string)
    user_data_base64        = optional(string)
    disable_api_termination = optional(bool, false)
    monitoring              = optional(bool, false)

    root_block_device = optional(object({
      volume_type           = optional(string, "gp3")
      volume_size           = optional(number, 20)
      delete_on_termination = optional(bool, true)
      encrypted             = optional(bool, true)
      kms_key_id            = optional(string)
    }), {})

    ebs_volumes = optional(map(object({
      device_name           = string
      volume_type           = optional(string, "gp3")
      volume_size           = number
      delete_on_termination = optional(bool, true)
      encrypted             = optional(bool, true)
      kms_key_id            = optional(string)
    })), {})
  }))
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Application Loadbalancer
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++

variable "lb_target_group_config" {
  description = "Map of ALB target groups"

  type = map(object({
    target_type = string
    protocol    = string
    port        = number

    health_check = object({
      enabled           = bool
      healthy_threshold = number
      interval          = number
      timeout           = number
      protocol          = string
      path              = string
    })
  }))
}


variable "lb_config" {
  description = "Application Load Balancer configuration"

  type = object({
    internal           = bool
    load_balancer_type = string
  })
}


variable "lb_listeners" {
  description = "Map of ALB listeners"

  type = map(object({
    port     = number
    protocol = string

    default_action = object({
      type             = string
      target_group_key = optional(string)

      redirect = optional(object({
        port        = optional(string, "443")
        protocol    = optional(string, "HTTPS")
        status_code = optional(string, "HTTP_301")
      }))

      fixed_response = optional(object({
        content_type = optional(string, "text/plain")
        message_body = optional(string, "")
        status_code  = optional(string, "404")
      }))
    })
  }))
}

variable "target_group_instances" {
  description = "Map of target groups to EC2 instance names"

  type = map(list(string))

  default = {}
}

# WAF

variable "waf_block_ip_addresses" {
  description = "IPv4 addresses/CIDRs to block with AWS WAF"
  type        = list(string)
  default     = []
}

variable "waf_enable_geo_block" {
  description = "Enable WAF geographic blocking"
  type        = bool
  default     = false
}

variable "waf_geo_block_countries" {
  description = "Country codes to block"
  type        = list(string)
  default     = []
}