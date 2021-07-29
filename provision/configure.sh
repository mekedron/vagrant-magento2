#!/bin/bash

echo '--- Configure ---'

# Mysql

# Create db user
echo '--- Configure: Mysql ---'
sudo sed -i 's/bind-address/#bind-address/' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i 's/skip-external-locking/#skip-external-locking/' /etc/mysql/mariadb.conf.d/50-server.cnf

sudo mysql -u root -e "CREATE USER IF NOT EXISTS '$VM_DB_USER'@'%' IDENTIFIED BY '$VM_DB_PASSWORD'"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$VM_DB_USER'@'%'"
sudo mysql -u root -e "FLUSH PRIVILEGES"

# Create db
#if [ "$VM_MAGENTO_INSTALL" == "true" ]; then
#    mysql -u root -p${VM_DB_PASSWORD} -e "DROP DATABASE IF EXISTS $VM_DB_NAME;"
#fi
sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS $VM_DB_NAME COLLATE 'utf8mb4_general_ci';"

# PHP
echo '--- Configure: PHP ---'

# remove old files
sudo rm -rf /etc/php/"$VM_PHP_VERSION"/fpm/conf.d/zz_*
sudo rm -rf /etc/php/"$VM_PHP_VERSION"/cli/conf.d/zz_*

sudo rm -rf /etc/php/"$VM_PHP_VERSION"/mods-available/zz_*

sudo rm -rf /etc/php/"$VM_PHP_VERSION"/fpm/pool.d/*

# copy new files
sudo cp /vagrant/provision/configs/php/php-fpm.conf /etc/php/"$VM_PHP_VERSION"/fpm/pool.d/php-fpm.conf
sudo cp /vagrant/provision/configs/php/* /etc/php/"$VM_PHP_VERSION"/mods-available/
sudo mv /etc/php/"$VM_PHP_VERSION"/mods-available/zz_php.ini /etc/php/"$VM_PHP_VERSION"/mods-available/zz_php_fpm.ini
sudo cp /etc/php/"$VM_PHP_VERSION"/mods-available/zz_php_fpm.ini /etc/php/"$VM_PHP_VERSION"/mods-available/zz_php_cli.ini


# fpm
sudo rm -rf /etc/php/"$VM_PHP_VERSION"/fpm/conf.d/20-xdebug.ini
sudo rm -rf /etc/php/"$VM_PHP_VERSION"/cli/conf.d/20-xdebug.ini
sudo ln -s /etc/php/"$VM_PHP_VERSION"/mods-available/zz_xdebug_fpm.ini /etc/php/"$VM_PHP_VERSION"/fpm/conf.d/zz_xdebug_fpm.ini
sudo ln -s /etc/php/"$VM_PHP_VERSION"/mods-available/zz_xdebug_cli.ini /etc/php/"$VM_PHP_VERSION"/cli/conf.d/zz_xdebug_cli.ini

# cli
sudo ln -s /etc/php/"$VM_PHP_VERSION"/mods-available/zz_php_fpm.ini /etc/php/"$VM_PHP_VERSION"/fpm/conf.d/zz_php_fpm.ini
sudo ln -s /etc/php/"$VM_PHP_VERSION"/mods-available/zz_php_cli.ini /etc/php/"$VM_PHP_VERSION"/cli/conf.d/zz_php_cli.ini

sudo sed -i "s/{PHP_VERSION}/${VM_PHP_VERSION}/" /etc/php/"$VM_PHP_VERSION"/fpm/pool.d/php-fpm.conf

sudo sed -i "s/{DEBUG_IP}/${VM_PHP_DEBUG_FPM_IP}/" /etc/php/"$VM_PHP_VERSION"/mods-available/zz_xdebug_fpm.ini
sudo sed -i "s/{DEBUG_IP}/${VM_PHP_DEBUG_CLI_IP}/" /etc/php/"$VM_PHP_VERSION"/mods-available/zz_xdebug_cli.ini

sudo sed -i "s/{MAX_EXECUTION}/60/" /etc/php/"$VM_PHP_VERSION"/mods-available/zz_php_fpm.ini
sudo sed -i "s/{MAX_EXECUTION}/0/" /etc/php/"$VM_PHP_VERSION"/mods-available/zz_php_cli.ini

sudo phpenmod zz_opcache

# NGINX
echo '--- Configure: NGINX ---'
sudo rm -rf /etc/nginx/sites-enabled/site.conf

sudo cp /vagrant/provision/configs/nginx/site.conf /etc/nginx/sites-enabled/site.conf
sudo sed -i "s/{PHP_VERSION}/${VM_PHP_VERSION}/" /etc/nginx/sites-enabled/site.conf
sudo sed -i "s/{SERVER_NAME}/${VM_SITE_HOST}/" /etc/nginx/sites-enabled/site.conf
sudo sed -i "s|{SITE_PATH}|${VM_SITE_PATH}|" /etc/nginx/sites-enabled/site.conf
if [ "${VM_SERVER_ALIASES}" != "" ]; then
    sudo sed -i "s/{SERVER_ALIASES}/${VM_SERVER_ALIASES}/" /etc/nginx/sites-enabled/site.conf
fi
if [ "${VM_SERVER_ALIASES}" == "" ]; then
    sudo sed -i "s/{SERVER_ALIASES}//" /etc/nginx/sites-enabled/site.conf
fi

# Composer
echo '--- Configure: Composer ---'
rm -rf /home/vagrant/.composer
mkdir -p /home/vagrant/.composer
cat <<EOF > /home/vagrant/.composer/auth.json
{
    "http-basic": {
        "repo.magento.com": {
            "username": "${VM_COMPOSER_MAGENTO_USERNAME}",
            "password": "${VM_COMPOSER_MAGENTO_PASSWORD}"
        }
    }
}
EOF
# cat <<EOF > /home/vagrant/.composer/config.json
# {
#     "config": {
#         "preferred-install": "source"
#     }
# }
# EOF

sudo chown -R vagrant:vagrant /home/vagrant/.composer

# Pupeter
#cp /vagrant/tools/bin/commands/advanced_js_building/process.js /home/vagrant/ajb/process.js
#sudo chown -R vagrant:vagrant /home/vagrant/ajb/process.js
