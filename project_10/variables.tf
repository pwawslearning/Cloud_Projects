variable "profile" {
  description = "profile to access AWS"
  default = "test-cli"
}
variable "tags" {
  description = "project name"
  default = "k8s"
}
variable "cidr_block" {
  description = "CIDR block for VPC"
  type = list(string)
  default = [ "10.0.0.0/16", "10.1.0.0/16", "10.2.0.0/16" ]
}
variable "cluster_name" {
  default = "k8s-cluster"
}
variable "k8s-version" {
  default = "1.31"
}