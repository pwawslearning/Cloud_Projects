#!/bin/bash
# Update package index
sudo apt install update -y
sudo apt-get update

# Install Apache web server
sudo apt install -y apache2

# Start Apache service
sudo systemctl start apache2

# Enable Apache to start on boot
sudo systemctl enable apache2

#Restart Apache service
sudo systemctl restart apache2

sudo apt install awscli -y

cd /var/www/html
sudo mkdir image
sudo aws s3 cp s3://apache-websvr-bk/Apache.png image/
sudo rm index.html
sudo aws s3 cp s3://apache-websvr-bk/index.html ./

#Restart Apache service
sudo systemctl restart apache2