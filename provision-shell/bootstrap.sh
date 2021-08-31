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
