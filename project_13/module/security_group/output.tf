output "security_group_ids" {
  description = "Security group IDs indexed by security group configuration key"

  value = {
    for security_group_key, security_group in aws_security_group.sg :
    security_group_key => security_group.id
  }
}