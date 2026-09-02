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

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Map of security group IDs indexed by logical group key"
  type        = map(string)
}

variable "project" {

}

variable "environment" {

}