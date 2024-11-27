variable "profile" {
  description = "profile to access AWS"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}
variable "vpc_azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
}
variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}
variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
