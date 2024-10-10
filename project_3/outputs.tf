output "haproxy1_ip" {
  value = docker_container.haproxy1.network_data
}

output "haproxy2_ip" {
  value = docker_container.haproxy2.network_data
}