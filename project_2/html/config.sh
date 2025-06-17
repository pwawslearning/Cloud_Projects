#!/bin/bash
# Update package index
sudo -su ubuntu
sudo apt update

# Install Apache web server
sudo apt install apache2 -y

# Start Apache service
sudo systemctl start apache2

# Enable Apache to start on boot
sudo systemctl enable apache2

#Restart Apache service
sudo systemctl restart apache2

cd /var/www/html
sudo apt install awscli -y
sudo mkdir image
sudo aws s3 cp s3://project-2-17062025-bucket02/Apache.png image/
sudo rm index.html
sudo aws s3 cp s3://project-2-17062025-bucket02/index.html ./

#Restart Apache service
sudo systemctl restart apache2