variable "profile" {
  type = string
}

variable "project-name" {
}

variable "vpc-cidr" {
  type = string
}

variable "public_subnet1" {
}

variable "public_subnet2" {
}

variable "private_subnet1" {
}

variable "private_subnet2" {
}

variable "image_id" {
}

variable "instance_type" {
}

variable "desired_capacity" {
  type = number
}

variable "max_size" {
  type = number
}
variable "min_size" {
  type = number
}
