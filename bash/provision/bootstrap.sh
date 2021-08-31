#!/bin/bash

BTC_DIR_ROOT="/vagrant/bash/provision"

# Include file
source "${BTC_DIR_ROOT}/../include/functions.sh"

# Install packages
sudo yum -y install bash-completion git

# Add the CentOS 7 EPEL repository
sudo yum -y install epel-release

# Install Nginx
sudo yum -y install nginx

# Change the access permissions
sudo chmod 755 /var/log/nginx/

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

# Install PHP extensions
sudo yum -y install php-xml

# Change user from "apache" to "nginx"
btc_strf_replace_once 'user = apache' 'user = nginx' '/etc/php-fpm.d/www.conf'

# Create group
sudo groupadd www-data

# Change user's primary group
sudo usermod -g www-data nginx

# Change group from "apache" to "www-data"
btc_strf_replace_once 'group = apache' 'group = www-data' '/etc/php-fpm.d/www.conf'

# Listen on a local socket file, since this improves the overall performance of the server
btc_strf_replace_once 'listen = 127.0.0.1:9000' 'listen = /var/run/php-fpm/php-fpm.sock' '/etc/php-fpm.d/www.conf'

# Change the owner and group settings for the socket file
btc_strf_replace_once ';listen.owner = nobody' 'listen.owner = nginx' '/etc/php-fpm.d/www.conf'
btc_strf_replace_once ';listen.group = nobody' 'listen.group = nginx' '/etc/php-fpm.d/www.conf'
btc_strf_replace ';listen.mode = 0660' 'listen.mode = 0660' '/etc/php-fpm.d/www.conf'

# Enable and start the php-fpm service
sudo systemctl start php-fpm

# Create dir if it does not exist
BTC_DIR='/etc/nginx/sites-available'
if [ ! -d "${BTC_DIR}" ]; then
    sudo mkdir "${BTC_DIR}"

    # Check "sites-enabled/"
    BTC_TMP_SEARCH=$(cat "${BTC_DIR_ROOT}/nginx/config/search-conf.conf")
    BTC_TMP_REPLACE=$(cat "${BTC_DIR_ROOT}/nginx/config/replace-conf.conf")
    BTC_TMP_FILE='/etc/nginx/nginx.conf'
    btc_strf_replace_once "${BTC_TMP_SEARCH}" "${BTC_TMP_REPLACE}" "${BTC_TMP_FILE}"
fi

# Copy file
sudo cp /vagrant/bash/provision/nginx/blockchain.conf "${BTC_DIR}"

# Use hostname
BTC_HOST=$(hostname)
btc_strf_replace_once 'node1.net' "${BTC_HOST}" '/etc/nginx/sites-available/blockchain.conf'

# Create dir if it does not exist
BTC_DIR='/etc/nginx/sites-enabled'
if [ ! -d "${BTC_DIR}" ]; then
    sudo mkdir "${BTC_DIR}"
fi

# Remove file
sudo rm -f /etc/nginx/sites-enabled/blockchain.conf

# Create symbolic link
sudo ln -s /etc/nginx/sites-available/blockchain.conf /etc/nginx/sites-enabled/blockchain.conf

# Restart Nginx to apply the changes
sudo systemctl restart nginx

# Remove dir
sudo rm -rf /var/www/blockchain

# Create symbolic link
sudo ln -s /vagrant/www /var/www/blockchain
