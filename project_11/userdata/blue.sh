#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
echo "<h1>Hello from BLUE Environment</h1>" > /var/www/html/index.html
systemctl start apache2
systemctl enable apache2
systemctl restart apache2
echo "Welcome to Blue Apache Server"