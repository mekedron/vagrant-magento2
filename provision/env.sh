#!/bin/bash

echo '--- Environment variables ---'

# Set environment variable
cat <<EOF > /etc/profile.d/env.sh
export VM_DB_NAME="${1}"
export VM_DB_USER="${2}"
export VM_DB_PASSWORD="${3}"
export VM_PHP_VERSION="${4}"
export VM_PHP_TIME_ZONE="${5}"
export VM_PHP_DEBUG_FPM_IP="${6}"
export VM_PHP_DEBUG_CLI_IP="${7}"
export VM_SITE_PATH="${8}"
export VM_SITE_HOST="${9}"
export VM_SERVER_ALIASES="${10}"
export VM_COMPOSER_MAGENTO_USERNAME="${11}"
export VM_COMPOSER_MAGENTO_PASSWORD="${12}"
export VM_MAGENTO_INSTALL="${13}"
export VM_MAGENTO_VERSION="${14}"
export VM_MAGENTO_EDITION="${15}"
export VM_MAGENTO_MODE="${16}"
export VM_MAGENTO_SAMPLE="${17}"
export VM_MAGENTO_LANGUAGE="${18}"
export VM_MAGENTO_CURRENCY="${19}"
export VM_MAGENTO_TIME_ZONE="${20}"
export VM_MAGENTO_ADMIN_EMAIL="${21}"
export VM_MAGENTO_ADMIN_LOGIN="${22}"
export VM_MAGENTO_ADMIN_PASS="${23}"

EOF
source /etc/profile.d/env.sh

# Source and display
source /etc/profile
cat /etc/profile.d/env.sh
