output "web_acl_id" {
  description = "WAF Web ACL ID"
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_name" {
  description = "WAF Web ACL name"
  value       = aws_wafv2_web_acl.this.name
}

output "ip_set_arn" {
  description = "Test IP blocklist ARN"
  value       = aws_wafv2_ip_set.block_ip_blocklist.arn
}