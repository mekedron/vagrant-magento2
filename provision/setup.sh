#!/bin/bash

echo '--- Setup ---'

# Postfix settings
sudo debconf-set-selections <<< "postfix postfix/mailname string $VM_SITE_HOST"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

# Add new repos and update apt
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update -y

# Required packages
echo '--- Install: Required packages ---'
sudo apt-get install -y \
  curl graphviz htop net-tools rsync sudo tree wget unzip zip \
  libsqlite3-dev libxml2-utils build-essential software-properties-common \
  postfix mailutils libsasl2-2 libsasl2-modules ca-certificates \
  apt-transport-https \
  openssl nginx redis-server \
  g++ vim git git-flow \
  libappindicator1 fonts-liberation

# mariadb
sudo apt-get install -y mariadb-server mariadb-client

# Set php version
MAGENTO_PHP_VERSION='7.2';
if $(dpkg --compare-versions "${VM_MAGENTO_VERSION}" "lt" "2.3"); then
  MAGENTO_PHP_VERSION='7.1';
fi
if $(dpkg --compare-versions "${VM_MAGENTO_VERSION}" "lt" "2.2"); then
  MAGENTO_PHP_VERSION='7.0';
fi
if [ $VM_PHP_VERSION != 'default' ]; then
  MAGENTO_PHP_VERSION=$VM_PHP_VERSION
fi

# Set php version env
sed -i '/export PHP_VERSION*/c\'"export VM_PHP_VERSION=${MAGENTO_PHP_VERSION}" /etc/profile.d/env.sh
source /etc/profile.d/env.sh

# PHP packages
echo '--- Install: PHP packages ---'
sudo apt-get install -y \
  php${VM_PHP_VERSION} php${VM_PHP_VERSION}-common php${VM_PHP_VERSION}-cli php${VM_PHP_VERSION}-fpm \
  php${VM_PHP_VERSION}-curl php${VM_PHP_VERSION}-gd php${VM_PHP_VERSION}-intl \
  php${VM_PHP_VERSION}-mbstring php${VM_PHP_VERSION}-soap php${VM_PHP_VERSION}-zip \
  php${VM_PHP_VERSION}-xml php${VM_PHP_VERSION}-xml php${VM_PHP_VERSION}-bcmath \
  php${VM_PHP_VERSION}-mysql php${VM_PHP_VERSION}-sqlite3 \
  php${VM_PHP_VERSION}-memcache php${VM_PHP_VERSION}-redis php${VM_PHP_VERSION}-opcache \
  php-pear php${VM_PHP_VERSION}-xdebug \
  python ruby ruby-dev
if [ "${VM_PHP_VERSION}" != "7.2" ]; then
  sudo apt-get install -y php${VM_PHP_VERSION}-mcrypt
fi

# Elasticsearch
sudo apt-get -y update
sudo apt-get install -y openjdk-8-jdk
sudo apt install elasticsearch
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch

# Composer
echo '--- Install: Composer ---'
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer --version=1.10.16

# Grunt
echo '--- Install: Grunt ---'
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get install -y nodejs
npm install -g grunt-cli
npm install -g gulp-cli

# Magerun
echo '--- Install: Magerun ---'
curl -sL -o /usr/local/bin/magerun https://files.magerun.net/n98-magerun2.phar
chmod +x /usr/local/bin/magerun

## Chrome
#wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#sudo dpkg -i --force-depends google-chrome-stable_current_amd64.deb
#sudo apt-get install -f -y
#rm -rf google-chrome-stable_current_amd64.deb

#Puppeter
#rm -rf /home/vagrant/ajb
#mkdir -p /home/vagrant/ajb
#cd /home/vagrant/ajb
# sudo npm config set puppeteer_skip_chromium_download true -g
#sudo npm i puppeteer

#sudo chown -R vagrant:vagrant /home/vagrant/ajb

# Clean
sudo apt-get -y upgrade
sudo apt-get -y clean autoclean
sudo apt-get -y autoremove
