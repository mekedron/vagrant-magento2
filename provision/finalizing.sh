#!/bin/bash

echo '--- Finalizing ---'

sudo systemctl start elasticsearch.service
sudo service mysql restart
sudo service php${VM_PHP_VERSION}-fpm restart

echo "Please execute 'sudo service nginx restart' to reboot nginx."
# sudo service nginx restart
