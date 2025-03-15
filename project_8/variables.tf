variable "project_name" {
  default = "project01"
}
variable "location" {
  default = "Canada Central"
}
variable "address_space" {
  default = "10.0.0.0/16"
}
variable "subnets" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}