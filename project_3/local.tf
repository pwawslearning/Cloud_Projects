resource "local_file" "index_file" {
  filename = "${path.module}/nginx/index.html"
  content  = <<-EOT
<html>
<body>

<h1>HAProxy with SSL for multiple docker containers by using Terraform (IaC)</h1>

<p>Goal is to access securly and loadbalance for multiple docker containers by using HAProxy and deploy all resources by using Terraform</p>

</body>
</html>
EOT
}

resource "local_file" "nginx_file" {
  filename = "${path.module}/nginx.conf"
  content  = <<-EOT
events {
    worker_connections 1024;
}

http {
    server {
        listen 443;
        server_name localhost;

        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
}
EOT
}

resource "local_file" "dockerfile" {
  filename = "${path.module}/Dockerfile"
  content  = <<-EOT
    # Use the official Nginx image as the base image
    FROM nginx:latest

    # Copy custom configuration file from the current directory to the container
    COPY nginx.conf /etc/nginx/nginx.conf

    # Copy static website files from the current directory to the container
    COPY nginx /usr/share/nginx/html

    # Expose port 443
    EXPOSE 443

    # Run Nginx in the foreground
    CMD ["nginx", "-g", "daemon off;"]
EOT
}
