#!/bin/bash

# Install Git
sudo yum -y install git

# Add the CentOS 7 EPEL repository
sudo yum -y install epel-release

# Install Nginx
sudo yum -y install nginx

# Start the Nginx service
sudo systemctl start nginx

# Enable Nginx to start on boot
sudo systemctl enable nginx

# Install the Remi repository for CentOS 7
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm

# Enable the correct Remi package to get PHP 7.4
sudo yum-config-manager --enable remi-php74

# Install all the required packages to get PHP 7.4 set up within Nginx
sudo yum -y install php php-fpm

# Change user from "apache" to "nginx"
sudo sh -c "sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf"

# Change group from "apache" to "nginx"
sudo sh -c "sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf"

# Listen on a local socket file, since this improves the overall performance of the server
sudo sh -c "sed -i 's#listen = 127.0.0.1:9000#listen = /var/run/php-fpm/php-fpm.sock#g' /etc/php-fpm.d/www.conf"

# Change the owner and group settings for the socket file
sudo sh -c "sed -i 's/;listen.owner = nobody/listen.owner = nginx/g' /etc/php-fpm.d/www.conf"
sudo sh -c "sed -i 's/;listen.group = nobody/listen.group = nginx/g' /etc/php-fpm.d/www.conf"
sudo sh -c "sed -i 's/;listen.mode = 0660/listen.mode = 0660/g' /etc/php-fpm.d/www.conf"

# Enable and start the php-fpm service
sudo systemctl start php-fpm

# Override the default server block
sudo cp /vagrant/bash/provision/nginx/default.conf /etc/nginx/conf.d/default.conf

# Restart Nginx to apply the changes
sudo systemctl restart nginx

# Create virtual host directory content
sudo mkdir /var/www/test
sudo chown vagrant:vagrant /var/www/test
cp /vagrant/bash/provision/php/index.php /var/www/test/index.php
