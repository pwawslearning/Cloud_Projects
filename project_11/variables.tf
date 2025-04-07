variable "profile" {
  default = "test-cli"
}
variable "cidr_block" {
  description = "CIDR block for the whole infra"
  default = "10.0.0.0/16"
}
variable "tags" {
  description = "for tagging and naming for AWS resources"
  default = "blue-green"
}