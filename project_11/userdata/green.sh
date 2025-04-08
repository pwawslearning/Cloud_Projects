#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
echo '<!DOCTYPE html><html><head><title>BLUE</title></head><body style="background-color:green;color:white;"><h1>Hello from GREEN Environment</h1></body></html>' > /var/www/html/index.html
systemctl start apache2
systemctl enable apache2
systemctl restart apache2
echo "Welcome to Green Apache Server"