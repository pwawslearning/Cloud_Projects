output "instance_ids" {
  description = "EC2 instance IDs by instance key"

  value = {
    for instance_name, instance in aws_instance.this :
    instance_name => instance.id
  }
}

output "private_ips" {
  description = "Private IP addresses by instance key"

  value = {
    for instance_name, instance in aws_instance.this :
    instance_name => instance.private_ip
  }
}

output "public_ips" {
  description = "Public IP addresses by instance key"

  value = {
    for instance_name, instance in aws_instance.this :
    instance_name => instance.public_ip
  }
}