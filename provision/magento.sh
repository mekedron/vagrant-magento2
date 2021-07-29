#!/bin/bash

echo '--- Magento ---'

MAGENTO_DIR=$VM_SITE_PATH

sudo mkdir -p "$MAGENTO_DIR"

sudo chown vagrant:vagrant "$MAGENTO_DIR"

# Install from magento
if [ "$VM_MAGENTO_INSTALL" == "true" ]; then
    sudo -i -u "vagrant" composer create-project --no-install --no-progress --repository=https://repo.magento.com/ magento/project-"$VM_MAGENTO_EDITION"-edition="$VM_MAGENTO_VERSION" "$MAGENTO_DIR" -d "$MAGENTO_DIR"
fi
# Install sample data
#if [ "$VM_MAGENTO_SAMPLE" == "true" ]; then
#    sudo -u "vagrant" composer require -d "$MAGENTO_DIR" \
#    magento/module-bundle-sample-data magento/module-widget-sample-data \
#    magento/module-theme-sample-data magento/module-catalog-sample-data \
#    magento/module-customer-sample-data magento/module-cms-sample-data \
#    magento/module-catalog-rule-sample-data magento/module-sales-rule-sample-data \
#    magento/module-review-sample-data magento/module-tax-sample-data \
#    magento/module-sales-sample-data magento/module-grouped-product-sample-data \
#    magento/module-downloadable-sample-data magento/module-msrp-sample-data \
#    magento/module-configurable-sample-data magento/module-product-links-sample-data \
#    magento/module-wishlist-sample-data magento/module-swatches-sample-data \
#    magento/sample-data-media magento/module-offline-shipping-sample-data
#fi

# Composer install
sudo -i -u "vagrant" composer install -d "$MAGENTO_DIR" --no-progress --no-suggest

# Run install
chmod +x "$MAGENTO_DIR"/bin/magento

# Install magento
if [ "$VM_MAGENTO_INSTALL" == "true" ]; then
    sudo -i -u "vagrant" "$MAGENTO_DIR"/bin/magento setup:uninstall -n -q
    sudo -i -u "vagrant" "$MAGENTO_DIR"/bin/magento setup:install \
        --base-url="http://${VM_SITE_HOST}/" \
        --db-host="localhost"  \
        --db-name="${VM_DB_NAME}" \
        --db-user="${VM_DB_USER}" \
        --db-password="${VM_DB_PASSWORD}" \
        --admin-firstname="admin" \
        --admin-lastname="admin" \
        --language="${VM_MAGENTO_LANGUAGE}" \
        --currency="${VM_MAGENTO_CURRENCY}" \
        --timezone="${VM_MAGENTO_TIME_ZONE}" \
        --admin-email="${VM_MAGENTO_ADMIN_EMAIL}" \
        --admin-user="${VM_MAGENTO_ADMIN_LOGIN}" \
        --admin-password="${VM_MAGENTO_ADMIN_PASS}" \
        --use-rewrites="1" \
        --backend-frontname="admin"

    # Magento config
    sudo -i -u "vagrant" "$MAGENTO_DIR"/bin/magento setup:config:set \
        --cache-backend=redis \
        --cache-backend-redis-server=127.0.0.1 \
        --cache-backend-redis-port=6379 \
        --cache-backend-redis-db=0 \
        --page-cache=redis \
        --page-cache-redis-server=127.0.0.1 \
        --page-cache-redis-port=6379 \
        --page-cache-redis-db=1 \
        --page-cache-redis-compress-data=1

    sudo -i -u "vagrant" "$MAGENTO_DIR"/bin/magento setup:config:set \
        --session-save=redis \
        --session-save-redis-host=127.0.0.1 \
        --session-save-redis-port=6379 \
        --session-save-redis-db=2

    sudo -i -u "vagrant" "$MAGENTO_DIR"/bin/magento config:set "admin/security/session_lifetime" "31536000"
    sudo -i -u "vagrant" "$MAGENTO_DIR"/bin/magento config:set "admin/security/lockout_threshold" "180"
    sudo -i -u "vagrant" "$MAGENTO_DIR"/bin/magento config:set "admin/security/password_lifetime" ""
    sudo -i -u "vagrant" "$MAGENTO_DIR"/bin/magento config:set "admin/security/password_is_forced" "0"
    sudo -i -u "vagrant" "$MAGENTO_DIR"/bin/magento config:set "web/secure/use_in_adminhtml" "1"

    # Clean compiled files
    rm -rf "$MAGENTO_DIR"/generated/code/
    sudo -i -u "vagrant" "$MAGENTO_DIR"/bin/magento setup:upgrade
    sudo -i -u "vagrant" "$MAGENTO_DIR"/bin/magento deploy:mode:set "$VM_MAGENTO_MODE"
    sudo -i -u "vagrant" "$MAGENTO_DIR"/bin/magento cache:enable
fi
