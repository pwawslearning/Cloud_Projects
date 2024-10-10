# Build docker image with created dockerfile
resource "docker_image" "mynginx" {
  name = "nginx_web:latest"
  build {
    context = "."
  }
}

# Run create as a container with created image
resource "docker_container" "ubuntu" {
  name  = "nginx_web"
  image = docker_image.mynginx.image_id
}

