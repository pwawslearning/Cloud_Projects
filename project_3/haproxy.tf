resource "local_file" "haproxy_file" {
  filename = "${path.module}/HAproxy/haproxy.cfg"
  content = <<-EOT
  global
  stats socket /var/run/api.sock user haproxy group haproxy mode 660 level admin expose-fd listeners
  log stdout format raw local0 info

defaults
  mode http
  timeout client 10s
  timeout connect 5s
  timeout server 10s
  timeout http-request 10s
  log global

frontend stats
  bind *:8404
  stats enable
  stats uri /
  stats refresh 10s

frontend https_frontend
  bind *:443 ssl crt /usr/local/etc/haproxy/haproxy.pem
  default_backend webservers

backend webservers
  server nginx1 ngweb1:443 check
  server nginx2 ngweb2:443 check
  server nginx3 ngweb3:443 check
  EOT
}

# Create new docker network
resource "docker_network" "mynetwork" {
  name = "mynetwork"
}

# pull image from repository
resource "docker_image" "my_image" {
  name = "pwawslearning/pw_nginx:latest"
}

#create container for webserver1
resource "docker_container" "ngweb1" {
  name  = "ngweb1"
  image = docker_image.my_image.image_id
  networks_advanced {
    name = docker_network.mynetwork.name
  }
  ports {
    internal = 443
    external = 6443
    protocol = "tcp"
  }
}

#create container for webserver2
resource "docker_container" "ngweb2" {
  name  = "ngweb2"
  image = docker_image.my_image.image_id
  networks_advanced {
    name = docker_network.mynetwork.name
  }
  ports {
    internal = 443
    external = 6444
    protocol = "tcp"
  }
}

#create container for webserver3
resource "docker_container" "ngweb3" {
  name  = "ngweb3"
  image = docker_image.my_image.image_id
  networks_advanced {
    name = docker_network.mynetwork.name
  }
  ports {
    internal = 443
    external = 6445
    protocol = "tcp"
  }
}

#Pull HAproxy image

resource "docker_image" "haproxy_image" {
  name = "haproxytech/haproxy-alpine:2.4"
  keep_locally = false
}

#Create containers for HAProxy

resource "docker_container" "haproxy1" {
  name  = "haproxy1"
  image = docker_image.haproxy_image.image_id

  networks_advanced {
    name = docker_network.mynetwork.name
  }

  volumes {
    host_path      = "${abspath(path.module)}/HAproxy"
    container_path = "/usr/local/etc/haproxy"
    read_only      = true
  }

  ports {
    internal = 443
    external = 8443
  }

  ports {
    internal = 8404
    external = 8404
  }
}

resource "docker_container" "haproxy2" {
  name  = "haproxy2"
  image = docker_image.haproxy_image.image_id

  networks_advanced {
    name = docker_network.mynetwork.name
  }

  volumes {
    host_path      = "${abspath(path.module)}/HAproxy"
    container_path = "/usr/local/etc/haproxy"
    read_only      = true
  }

  ports {
    internal = 443
    external = 8444
  }

  ports {
    internal = 8404
    external = 8405
  }
}
