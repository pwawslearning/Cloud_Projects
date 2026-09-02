variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}


# ---------------------------------------------------------
# Target Groups
# ---------------------------------------------------------

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


# ---------------------------------------------------------
# ALB Security Groups
# ---------------------------------------------------------

variable "lb_security_group" {
  description = "Security group IDs for the ALB"
  type        = list(string)
}


# ---------------------------------------------------------
# ALB Subnets
# ---------------------------------------------------------

variable "lb_subnets" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}


# ---------------------------------------------------------
# ALB Configuration
# ---------------------------------------------------------

variable "lb_config" {
  description = "Application Load Balancer configuration"

  type = object({
    internal           = bool
    load_balancer_type = string
  })
}


# ---------------------------------------------------------
# ALB Listeners
# ---------------------------------------------------------

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
  description = "Map of target group keys to EC2 instance IDs"

  type    = map(list(string))
  default = {}
}

variable "instance_ids" {
  description = "Map of EC2 instance names to instance IDs"
  type        = map(string)
}