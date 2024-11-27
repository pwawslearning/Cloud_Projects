module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "5.16.0"
  cidr            = var.vpc_cidr
  azs             = var.vpc_azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  map_public_ip_on_launch = true
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
}

