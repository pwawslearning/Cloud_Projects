variable "cidr_block" {
  type    = string
  default = "10.0.0.0/20"
}

variable "project" {
  type = string
}

variable "public_subnets" {
  type    = number
  default = 2
}

variable "private_subnets" {
  type    = number
  default = 2
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "eip_count" {
  type    = number
  default = 1
}

variable "natgw_count" {
  type    = number
  default = 1
}
