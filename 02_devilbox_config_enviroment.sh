#! /bin/bash

## 
## This script configurates Devilbox enviroment for a particular magento version
##
## $magento_version: string     magento version to install or config devilbox to
## in help_function you can see required parameters
##

# includes
source "$PWD/includes/variables.sh"
source "$PWD/includes/functions.sh"

# help menu, require options, feedback user
setMagentoVersion()
{
    magento_version=$1
}

askInstallDefaultMagentoVersion()
{
    # User has not provided magento_version parameter, so install default version?
    read -p "Install default Magento version [${magento_version_default}]? (y/n)" decision
    case $decision in
        y ) setMagentoVersion $magento_version_default; return 1 ;;
        n ) helpFunction; return 0 ;;
    esac

    exit 1
}

helpFunction()
{
   echo ""
   echo "Usage: $0 -m magento_version"
   echo -e "\t-m Magento version you want to install or config devilbox to"
   
   exit 1
}

# sets all enviroment variables that devilbox needs in order to get configurated
function set_env_variables_for_magento_version {
  _error_count=0

  # dbox_PHP_SERVER
   case $magento_version in
    "2.4.1"|"2.4.2")
      dbox_PHP_SERVER="PHP_SERVER=7.4" ;;
    *)
      ((_error_count++))
      echo -e "${T_CRED}Could not set dbox_PHP_SERVER. Aborting.${T_CNCOLOR}"
      ;;
  esac

  # dbox_HTTPD_SERVER
  case $magento_version in
    "2.4.1"|"2.4.2")
      dbox_HTTPD_SERVER="HTTPD_SERVER=apache-2.4" ;;
    *)
      ((_error_count++))
      echo -e "${T_CRED}Could not set dbox_HTTPD_SERVER. Aborting.${T_CNCOLOR}"
      ;;
  esac

  # dbox_MYSQL_SERVER
  case $magento_version in
    "2.4.1"|"2.4.2")
      dbox_MYSQL_SERVER="MYSQL_SERVER=mysql-8.0" ;;
    *)
      ((_error_count++))
      echo -e "${T_CRED}Could not set dbox_MYSQL_SERVER. Aborting.${T_CNCOLOR}"
      ;;
  esac

  # dbox_REDIS_SERVER
  case $magento_version in
    "2.4.1"|"2.4.2")
      dbox_REDIS_SERVER="REDIS_SERVER=5.0" ;;
    *)
      ((_error_count++))
      echo -e "${T_CRED}Could not set dbox_REDIS_SERVER. Aborting.${T_CNCOLOR}"
      ;;
  esac

  # php_version_for_ini="7.4"
  case $magento_version in
    "2.4.1"|"2.4.2")
      php_version_for_ini="7.4" ;;
    *)
      ((_error_count++))
      echo -e "${T_CRED}Could not set php_version_for_ini. Aborting.${T_CNCOLOR}"
      ;;
  esac

  # magento_version_for_docker_compose_override="2.4"
  case $magento_version in
    "2.4.1"|"2.4.2")
      magento_version_for_docker_compose_override="2.4" ;;
    *)
      ((_error_count++))
      echo -e "${T_CRED}Could not set magento_version_for_docker_compose_override. Aborting.${T_CNCOLOR}"
      ;;
  esac

  # magento_version_for_start_script
  case $magento_version in
    "2.4.1"|"2.4.2")
      magento_version_for_start_script="2.4" ;;
    *)
      ((_error_count++))
      echo -e "${T_CRED}Could not set magento_version_for_start_script. Aborting.${T_CNCOLOR}"
      ;;
  esac

  if (( $_error_count > 0 )); then
      echo -e "${T_CRED}There some errors setting .env variables. Fix them and retry.${T_CNCOLOR}"
      exit 1
  fi
}

while getopts "m:" opt
do
    case "$opt" in
        m ) magento_version="$OPTARG" ;;
        ? ) askInstallDefaultMagentoVersion ;; # Ask for default magento version installation in case parameter is non-existent
    esac
done

# Ask for default magento version installation in case parameters are empty
if [ -z "$magento_version" ]; then
   askInstallDefaultMagentoVersion
fi

##
##
##
## Check devilbox enviroment
##
##
##

check_dbox





##
##
##
## Prepare devilbox enviroment
##
## After these steps, you can perform a ./_start.sh in devilbox dir to run Devilbox
## with all customizations perfrormed
##
##
##

echo "02 ---> creating needing directories and config files...";

create_new_env_file

set_env_variables_for_magento_version

replaces_env

enable_additional_containers

customize_php_ini

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


