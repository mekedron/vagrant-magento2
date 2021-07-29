# Requiered plugins
# -*- mode: ruby -*-
# vi: set ft=ruby :
rootPath = File.dirname(__FILE__)
require 'yaml'
require "#{rootPath}/dependency.rb"

# Load yaml configuration
vConfig = YAML.load_file("#{rootPath}/config.yaml")

# Check plugin
check_plugins ['vagrant-hostsupdater', 'vagrant-vbguest', 'vagrant-mutagen', 'vagrant-disksize']

# Vagrant configureHypervisorType
Vagrant.configure("2") do |config|
    # Virtual machine
    config.vm.box = vConfig['vmconf']['box']

    # Disable vbguest auto update
    config.vbguest.auto_update = false

    # Host manager configuration
    config.vm.network :private_network, ip: vConfig['vmconf']['network_ip']

    # VBox config
    config.vm.provider 'virtualbox' do |v|
        # Basic Settings
        v.name   = vConfig['vmconf']['machine_name']
        v.memory = vConfig['vmconf']['memory']
        v.cpus   = vConfig['vmconf']['cpus']

        #v.linked_clone = false
        #v.update_guest_tools = false
        # Use multiple CPUs in VM
        v.customize ['modifyvm', :id, '--ioapic', 'on']
    end

    # Virtualhosts
    config.vm.hostname = vConfig['magento']['url']
    config.hostsupdater.aliases = vConfig['magento']['url_aliases'].split(" ")

    # Default options
    config.vm.synced_folder './provision', '/vagrant/provision'
    # config.vm.synced_folder './tools', '/vagrant/tools'
    # config.vm.synced_folder './data', '/vagrant/data'

    # Project synchronization settings
    if vConfig['folders']['magento']['use_mutagen'] == "true"
        config.mutagen.orchestrate = true
    else
        config.vm.synced_folder vConfig['folders']['magento']['src'], vConfig['folders']['magento']['dest'],
            type: 'nfs',
            mount_options: ['nolock', 'rw', 'vers=3', 'tcp', 'fsc', 'actimeo=2'],
            linux__nfs_options: ['nolock', 'rw', 'vers=3', 'tcp', 'fsc', 'actimeo=2', 'no_subtree_check', 'no_root_squash']#,
            #map_uid: 0,
            #map_gid: 0
    end

    # Environment provisioning
    config.vm.provision 'shell', path: 'provision/env.sh', run: 'always', keep_color: true, args: [
        vConfig['db']['name'],                              # 1         VM_DB_NAME
        vConfig['db']['user'],                              # 2         VM_DB_USER
        vConfig['db']['password'],                          # 3         VM_DB_PASSWORD
        vConfig['server']['php_version'],                   # 4         VM_PHP_VERSION
        vConfig['server']['time_zone'],                     # 5         VM_PHP_TIME_ZONE
        vConfig['server']['php_debug_fpm_ip'],              # 6         VM_PHP_DEBUG_FPM_IP
        vConfig['server']['php_debug_cli_ip'],              # 7         VM_PHP_DEBUG_CLI_IP
        vConfig['server']['site_folder'],                   # 8         VM_SITE_PATH
        vConfig['magento']['url'],                          # 9         VM_SITE_HOST
        vConfig['magento']['url_aliases'],                  # 10        VM_SERVER_ALIASES
        vConfig['composer']['magento']['username'],         # 11        VM_COMPOSER_MAGENTO_USERNAME
        vConfig['composer']['magento']['password'],         # 12        VM_COMPOSER_MAGENTO_PASSWORD
        vConfig['magento']['install'],                      # 13        VM_MAGENTO_INSTALL
        vConfig['magento']['version'],                      # 14        VM_MAGENTO_VERSION
        vConfig['magento']['edition'],                      # 15        VM_MAGENTO_EDITION
        vConfig['magento']['mode'],                         # 16        VM_MAGENTO_MODE
        vConfig['magento']['sample'],                       # 17        VM_MAGENTO_SAMPLE
        vConfig['magento']['language'],                     # 18        VM_MAGENTO_LANGUAGE
        vConfig['magento']['currency'],                     # 19        VM_MAGENTO_CURRENCY
        vConfig['magento']['time_zone'],                    # 20        VM_MAGENTO_TIME_ZONE
        vConfig['magento']['admin_email'],                  # 21        VM_MAGENTO_ADMIN_EMAIL
        vConfig['magento']['admin_login'],                  # 22        VM_MAGENTO_ADMIN_LOGIN
        vConfig['magento']['admin_pass']                    # 23        VM_MAGENTO_ADMIN_PASS
    ]

    config.vm.provision 'shell', path: 'provision/setup.sh', keep_color: true
    config.vm.provision 'shell', path: 'provision/configure.sh', keep_color: true
    config.vm.provision 'shell', path: 'provision/magento.sh', keep_color: true, privileged: false
    config.vm.provision 'shell', path: 'provision/finalizing.sh', keep_color: true, privileged: false
end
