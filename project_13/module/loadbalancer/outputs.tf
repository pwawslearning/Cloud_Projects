output "alb_id" {
  description = "ALB ID"
  value       = aws_lb.alb.id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.alb.arn
}

output "alb_dns" {
  description = "ALB DNS name"
  value       = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  description = "ALB Route53 Zone ID"
  value       = aws_lb.alb.zone_id
}

output "target_group_arns" {
  description = "Target group ARNs"

  value = {
    for key, tg in aws_lb_target_group.lb_tg :
    key => tg.arn
  }
}

output "listener_arns" {
  description = "ALB listener ARNs"

  value = {
    for key, listener in aws_lb_listener.this :
    key => listener.arn
  }
}