output "instance_ids" {
  value = module.instances.instance_ids
}

output "instance_private_ips" {
  value = module.instances.private_ips
}

output "instance_public_ips" {
  value = module.instances.public_ips
}

output "alb_dns" {
  value = module.Loadbalancer.alb_dns
}

output "alb_arn" {
  value = module.Loadbalancer.alb_arn
}