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

##
##
##
## Variables
##
##
##

# system
comm_num_params="$#"
source "$PWD/variables"

# get devilbox and its www projects dir

dbox_dir="$MYUSER_HOME_DIR/devilbox"
dbox_www_dir="$MYUSER_HOME_DIR/www-projects"
dbox_env_file="$dbox_dir/env-example"


##
##
##
## Functions
##
##
##

function check_dbox_dir {
    if [ ! -d $dbox_dir ]; then
        echo "Error: $dbox_dir does not exist..."
        exit 1
    fi
}

function check_dbox_www_dir {
    if [ ! -d $dbox_www_dir ]; then
        echo "Error: $dbox_www_dir does not exist..."
        exit 1
    fi
}

function check_dbox_env_file {
    if [ ! -f $dbox_env_file ]; then
        echo "Error: $dbox_env_file does not exist..."
        exit 1
    fi
}

function create_project_dir {
    _project_dir="$dbox_www_dir/$project_name"

    if [ ! -d "$_project_dir" ]; then
        mkdir -p "$_project_dir/htdocs"
        chown -R $MYUSER:$MYUSER $_project_dir
        
        echo "-- $_project_dir created"

        return 0
    fi

    echo "Error: $_project_dir already exists! Delete it first"
}

function create_local_hosts_entry {
    _input="/etc/hosts"
    _entry="127.0.0.1 $project_name.loc"
    _entry_counter=0

    # find that entry in the hosts file, returns > 0 if found
    while IFS= read -r line
    do
        if [ "$line" = "$_entry" ]; then
            ((_entry_counter++))
        fi
    done < "$_input"

    if ((_entry_counter > 0)); then
        echo "'$_entry' already found $_entry_counter times!!"
    else
        echo $_entry >> "/etc/hosts"
        echo "-- '$_entry' updated in hosts file"
    fi
}





##
##
##
## Print help and check command line arguments
##
##
##

helpFunction()
{
   echo ""
   echo "Usage: $0 -p project_name -b parameterB"
   echo -e "\t-p Description of what is project_name"
   echo -e "\t-b Description of what is parameterB"
   exit 1
}

while getopts "p:b:" opt
do
    case "$opt" in
        p ) project_name="$OPTARG" ;;
        b ) parameterB="$OPTARG" ;;
        ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
    esac
done

# Print helpFunction in case parameters are empty
if [ -z "$project_name" ] || [ -z "$parameterB" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi





##
##
##
## Check devilbox enviroment
##
##
##

# echo "01 ---> checking deviblox enviroment...";

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


create_project_dir

create_local_hosts_entry

function create_new_env_file {
    # TODO remove rm statement
        rm "$dbox_dir/.env"

    if [ -f "$dbox_dir/.env" ]; then
        echo "Error: .env file already exists!! Delete ir first"
        exit 1
    fi

    cp "$dbox_env_file" "$dbox_dir/.env"
    chown -R $MYUSER:$MYUSER "$dbox_dir/.env"

    echo "-- new .env file created"
}
create_new_env_file

function replaces_env {
    _file="$dbox_dir/.env"
    
    if [ ! -f "$_file" ]; then
        echo "Error: no .env file found"
        exit 1
    fi

    ## php
    # php 7_4 already enabled by default

    ## web server
    # disable nginx_stable
    service="HTTPD_SERVER=nginx-stable"
    service_search="$service"
    service_replace="#$service"
    sed -i "s/$service_search/$service_replace/" $_file

    # enable apache_2_4
    service="HTTPD_SERVER=apache-2.4"
    service_search="#$service"
    service_replace="$service"
    sed -i "s/$service_search/$service_replace/" $_file

    echo "-- $service"

    ## database engine
    # disable mariadb
    service="MYSQL_SERVER=mariadb-10.5"
    service_search="$service"
    service_replace="#$service"
    sed -i "s/$service_search/$service_replace/" $_file

    # enable mysql
    service="MYSQL_SERVER=mysql-8.0"
    service_search="#$service"
    service_replace="$service"
    sed -i "s/$service_search/$service_replace/" $_file
    
    echo "-- $service"

    ## redis
    # disable redis_6
    service="REDIS_SERVER=6.0"
    service_search="$service"
    service_replace="#$service"
    sed -i "s/$service_search/$service_replace/" $_file
    # fix: delete double # in redis_6_alpine
    service="REDIS_SERVER=6.0-alpine"
    service_search="##$service"
    service_replace="#$service"
    sed -i "s/$service_search/$service_replace/" $_file

    # enable redis_5
    service="REDIS_SERVER=5.0"
    service_search="#$service"
    service_replace="$service"
    sed -i "s/$service_search/$service_replace/" $_file
    # fix: disable redis_5_alpine
    service="REDIS_SERVER=5.0-alpine"
    service_search="$service"
    service_replace="#$service"
    sed -i "s/$service_search/$service_replace/" $_file
    
    echo "-- $service"

    ## local fylesystem
    # change local project dir 
    service='HOST_PATH_HTTPD_DATADIR\=\.\/data\/www'
    service_search=$service
    service_replace='HOST_PATH_HTTPD_DATADIR\=\.\.\/www-projects'
    sed -i "s/$service_search/$service_replace/" $_file
    
    ## disable php modules
    service="PHP_MODULES_DISABLE=oci8,PDO_OCI,pdo_sqlsrv,sqlsrv,rdkafka,swoole"
    service_search="$service"
    service_replace="PHP_MODULES_DISABLE=oci8,PDO_OCI,pdo_sqlsrv,sqlsrv,rdkafka,swoole,psr" # remove psr: conflicts because of a bug
    sed -i "s/$service_search/$service_replace/" $_file

    echo "-- $service"
}
replaces_env

# additional containers
function enable_additional_containers {
    _file_name="docker-compose.override.yml"
    _file_path="$dbox_dir/$_file_name"

    # TODO delete rm line
    rm $_file_path

    if [ -f "$_file_path" ]; then
        echo "Error: $_file_path already exists! Delete it first"
        exit 1
    fi

    cp "to_copy/$_file_name" "$_file_path"
    chown -R $MYUSER:$MYUSER $_file_path

    echo "-- $_file_path created"
}
enable_additional_containers

# customize php.ini settings
function customize_php_ini {
    _file_name="custom.ini"
    _file_path="$dbox_dir/cfg/php-ini-7.4/$_file_name"

    # TODO delete rm line
    rm $_file_path

    if [ -f "$_file_path" ]; then
        echo "Error: $_file_path already exists! Delete it first"
        exit 1
    fi

    cp "to_copy/$_file_name" "$_file_path"
    chown -R $MYUSER:$MYUSER $_file_path

    echo "-- $_file_path created"
}
customize_php_ini


# create start devilbox script: httpd, php, mysql, mailhog, elasitcsearch
function create_start_dbox_script {
    _file_name="_start.sh"
    _file_path="$dbox_dir/$_file_name"

    # TODO delete rm line
    rm $_file_path

    if [ -f "$_file_path" ]; then
        echo "Error: $_file_path already exists! Delete it first"
        exit 1
    fi

    cp "to_copy/$_file_name" "$_file_path"
    chown -R $MYUSER:$MYUSER $_file_path
    chmod +x $_file_path

    echo "-- $_file_path created"
}
create_start_dbox_script

# prepare install scripts inside container





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


