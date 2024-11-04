#!/bin/bash

#install awscli v2
curl -o awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
sudo apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install

# install webserver and mysql
sudo apt update
sudo apt install apache2 -y
sudo apt install php -y
sudo apt install php-mysql -y
sudo apt install mysql-server -y
systemctl status mysql

#data transfer
cd /var/www/html
sudo aws s3 cp s3://t2-webapp-bucket01/index.php .
sudo aws s3 cp s3://t2-webapp-bucket01/insert.php .
sudo aws s3 cp s3://t2-webapp-bucket01/fetch.php .
sudo aws s3 cp s3://t2-webapp-bucket01/config.php .
sudo aws s3 cp s3://t2-webapp-bucket01/merlin.jpg .
sudo rm index.html
