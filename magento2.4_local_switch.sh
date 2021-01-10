#! /bin/bash

##
## This script downloads and installs a magento 2.4.x instance
## and prepares a local enviroment for it in Devilbox
##

##
## NOTAS:
##
## caso 01) crear nuevo magento 2.4 (lo hace todo) 
##          -> magento2.4_local_switch.sh
## caso 02) adaptar entorno devilbox a magento 2.4 con proyecto existente 
##              -> magento2.4_local_create.sh
##              (no crea proj dir, no crea entrada hosts, no crea install script)
##
## en ambos casos, ejecutare ./_start.sh
## en el primer caso, me meto en el contenedor php y ejecuto ademas el install script
##

# includes
source "$PWD/includes/variables.sh"
source "$PWD/includes/functions.sh"


# TODO set variables for the replaces_env function 
# (when devilbox updates, we need to set what to service enabled by default to disable)

# TODO set a php version variable, so when copying custom.ini we cane
# refference the correct directory

# TODO create magento_loca_switch as entry point, ask for magento version so
# we can execute that <version>/magento<version>_local_switch.sh. In <version> dir
# we can have packed all files to copy and this specific version variables (as php version)

##
##
##
## Check devilbox enviroment
##
##
##

echo "01 ---> checking deviblox enviroment...";

check_dbox_dir

check_dbox_www_dir

check_dbox_env_file





##
##
##
## Prepare devilbox enviroment
##
##
##

echo "02 ---> creating needing directories and config files...";


create_new_env_file

replaces_env

# additional containers
enable_additional_containers

# customize php.ini settings
customize_php_ini


# create start devilbox script: httpd, php, mysql, mailhog, elasitcsearch
create_start_dbox_script





##
##
##
## Start devilbox and enter php container
##
##
##

# start devilbox

# composer-v1 (/usr/local/bin/comoser-1) /usr/local/bin/composer-1 y si quieres meterlo como symlink en /usr/local/bin

# create mysql database and grant access

# check php requirements: https://devdocs.magento.com/guides/v2.4/install-gde/prereq/php-settings.html 







##
##
##
## Download Magento
##
##
##

# downloads and install composer packages, will ask for magento repo keys and if need to store credentials
# composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.1 ./htdocs






##
##
##
## Install Magento
##
##
##

# permissions
# find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
# find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
# chown -R :devilbox .
# chmod u+x bin/magento

# php -d memory_limit=-1 bin/magento setup:install --base-url=http://my-marval.loc/ --db-host=127.0.0.1 --db-name=my-marval --db-user=root --admin-firstname=admin --admin-lastname=admin --admin-email=admin@admin.com --admin-user=admin --admin-password=g9egcwUE6WEGsyw98kKB4hu --language=en_US --currency=EUR --timezone=Europe/Madrid --use-rewrites=1 --search-engine=elasticsearch7 --elasticsearch-host=172.16.238.240 --elasticsearch-port=9200

# php magento deploy:mode:set developer

# php -d memory_limit=-1 /usr/local/bin/composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.1 ./htdocs

# configure 2FA or disable module
# si vacio: select * from core_config_data where path like '%provider%';
# insert into core_config_data(scope,scope_id,path,`value`) values ('default',0,'twofactorauth/general/force_providers','google'); 
# si no vacio
# update core_config_data set `value`='google' where path= 'twofactorauth/general/force_providers';

# base64 of the passkey Comonline123
# INXW233ONRUW4ZJRGIZQ====

# set base64 passkey for 2FA
# php bin/magento security:tfa:google:set-secret admin INXW233ONRUW4ZJRGIZQ====







##
##
##
## Post installation steps https://docs.google.com/document/d/1fa1HAW7axn3xfX_Wr7B4wxTceLLi2LHRuqHf7q3EVU4/edit?usp=sharing
##
##
##

# Install Pestle

# Download Module Comonline/common from bitbucket repo

# Download Language pack from bitbucket repo

# Download example import images forom bitbucket repo

# Install mageplaza smtp

# Intall mageplaza spanish language pack

# php bin/magento setup:upgrade

# Prepare grunt files for local development


