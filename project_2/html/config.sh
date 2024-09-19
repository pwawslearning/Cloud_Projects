#!/bin/bash
# Update package index
sudo -su ubuntu
sudo apt-get update

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
sudo aws s3 cp s3://apache-websvr-bk/Apache.png image/
sudo rm index.html
sudo aws s3 cp s3://apache-websvr-bk/index.html ./

#Restart Apache service
sudo systemctl restart apache2