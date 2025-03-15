variable "project_name" {
  default = "project01"
}
variable "location" {
  type = list(string)
  default = ["Canada Central", "West Europe", "Southeast Asia"]
}
variable "address_space" {
  default = "10.0.0.0/16"
}
variable "subnets" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "sku_size" {
  type = list(string)
  default = [ "Standard_B1s", "Standard_B1ms", "Standard_B2s" ]
}