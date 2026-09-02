module "Network" {
  source  = "./module/networking"
  project = var.project
}

module "Security_Group" {
  source                 = "./module/security_group"
  vpc_id                 = module.Network.vpc_id
  security_groups_config = var.security_groups_config
}

module "instances" {
  source      = "./module/compute"
  project     = var.project
  environment = var.environment
  instances   = var.instances

  public_subnet_ids  = module.Network.public_subnet_ids
  private_subnet_ids = module.Network.private_subnet_ids
  security_group_ids = module.Security_Group.security_group_ids
}

module "Loadbalancer" {
  source = "./module/loadbalancer"

  project     = var.project
  environment = var.environment

  vpc_id = module.Network.vpc_id

  lb_target_group_config = var.lb_target_group_config

  lb_security_group = [
    module.Security_Group.security_group_ids["alb"]
  ]

  lb_subnets = module.Network.public_subnet_ids

  lb_config    = var.lb_config
  lb_listeners = var.lb_listeners

  instance_ids = module.instances.instance_ids

  target_group_instances = {
    app = [
      "app01",
      "app02"
    ]
  }
}

module "WAF" {
  source = "./module/waf"

  project     = var.project
  environment = var.environment

  alb_arn = module.Loadbalancer.alb_arn

  block_ip_addresses = var.waf_block_ip_addresses

  enable_geo_block    = var.waf_enable_geo_block
  geo_block_countries = var.waf_geo_block_countries
}