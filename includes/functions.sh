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

function check_dbox {
    echo "01 ---> checking deviblox enviroment...";

    check_dbox_dir

    check_dbox_www_dir

    check_dbox_env_file
}


## creates .env file from env-example
function create_new_env_file {
    # TODO remove rm statement
        rm "$dbox_dir/.env" > /dev/null 2>&1

    if [ -f "$dbox_dir/.env" ]; then
        echo "Error: .env file already exists!! Delete ir first"
        exit 1
    fi

    cp "$dbox_env_file" "$dbox_dir/.env"
    chown -R $MYUSER:$MYUSER "$dbox_dir/.env"

    echo "    -- new .env file created"
}

## .env replace to enable line
function replaces_env_enable {
    service="$1"

    service_search="#$service"
    service_replace="$service"
    sed -i "s/$service_search/$service_replace/" $_file

    echo "    ++ $service enabled"
}

## .env replace to disable line
function replaces_env_disable {
    service=$1
    
    service_search="$service"
    service_replace="#$service"
    sed -i "s/$service_search/$service_replace/" $_file

    echo "    -- $service disabled"
}

## .env base fylesystem replace
function replaces_env_fylesystem {
    # change local project dir 
    line='HOST_PATH_HTTPD_DATADIR\=\.\/data\/www'
    line_search=$line
    line_replace='HOST_PATH_HTTPD_DATADIR\=\.\.\/www-projects'

    sed -i "s/$line_search/$line_replace/" $_file

    echo "    -- HOST_PATH_HTTPD_DATADIR\=\.\.\/www-projects"
}

## .env replaces for specific magento 2.4.1 version
function replaces_env_2_4_1 {
    ## php
    # php 7_4 already enabled by default

    ## web server
    replaces_env_disable "HTTPD_SERVER=nginx-stable"

    replaces_env_enable "HTTPD_SERVER=apache-2.4"

    ## database engine
    replaces_env_disable "MYSQL_SERVER=mariadb-10.5"

    replaces_env_enable "MYSQL_SERVER=mysql-8.0"

    ## redis
    replaces_env_disable "REDIS_SERVER=6.0"
    
    # fix: delete double # in redis_6_alpine
    ## TODO: make it another way so this does not have to be fixed
    service="REDIS_SERVER=6.0-alpine"
    service_search="##$service"
    service_replace="#$service"
    sed -i "s/$service_search/$service_replace/" $_file

    replaces_env_enable "REDIS_SERVER=5.0"
    
    # fix: disable redis_5_alpine
    ## TODO: make it another way so this does not have to be fixed
    replaces_env_disable "REDIS_SERVER=5.0-alpine"

    ## local fylesystem
    replaces_env_fylesystem
    
    ## disable php modules
    php_mods="PHP_MODULES_DISABLE=oci8,PDO_OCI,pdo_sqlsrv,sqlsrv,rdkafka,swoole"
    php_mods_search="$php_mods"
    php_mods_replace="PHP_MODULES_DISABLE=oci8,PDO_OCI,pdo_sqlsrv,sqlsrv,rdkafka,swoole,psr" # remove psr: conflicts because of a bug
    sed -i "s/$php_mods_search/$php_mods_replace/" $_file

    echo "    -- $php_mods php modules disabled"
}

## makes necessary .env replaces depending on magento version
## params   $1: magento version string
function replaces_env {
    _file="$dbox_dir/.env"
    
    if [ ! -f "$_file" ]; then
        echo "Error: no .env file found"
        exit 1
    fi

    case "$1" in
        2.4.1 ) replaces_env_2_4_1 ;;
        * ) echo "Error ${FUNCNAME[0]}: magento version provided is not available in script yet!!!"; exit 1 ;;
    esac
}

## creates docker-compose.override.yml to enable additional containers in devilbox
## parameters:  $1 magento version string
##              $dbox_www_dir devilbox projects dir path
##              $project_name string asked to the user
function enable_additional_containers {
    if [ $# -eq 0 ]; then
        echo "Error ${FUNCNAME[0]}: you must provide a magento version parameter"

        exit 1
    fi
    
    _file_name="docker-compose.override.yml"
    _file_path="$dbox_dir/$_file_name"
    _origin_file_path="to_copy/docker-compose.override/$1/$_file_name"

    # TODO delete rm line
    rm $_file_path > /dev/null 2>&1

    if [ -f "$_file_path" ]; then
        echo "Error: $_file_path already exists! Delete it first"
        exit 1
    fi

    cp "$_origin_file_path" "$_file_path"
    chown -R $MYUSER:$MYUSER $_file_path

    echo "    -- $_file_path created"
}

## customizes php.ini by createing custom.ini inside devilbox config php files
## parameters:  $1 magento version string
function customize_php_ini {
    if [ $# -eq 0 ]; then
        echo "Error ${FUNCNAME[0]}: you must provide a magento version parameter"

        exit 1
    fi

    case "$1" in
        2.4.1 ) php_version=7.4 ;;
        * ) echo "Error ${FUNCNAME[0]}: magento version provided is not available in script yet!!!"; exit 1 ;;
    esac

    _file_name="custom.ini"
    _file_path="$dbox_dir/cfg/php-ini-$php_version/$_file_name"
    _origin_file_path="to_copy/php.ini/$php_version/custom.ini"

    # TODO delete rm line
    rm $_file_path > /dev/null 2>&1

    if [ -f "$_file_path" ]; then
        echo "Error: $_file_path already exists! Delete it first"
        exit 1
    fi

    cp "$_origin_file_path" "$_file_path"
    chown -R $MYUSER:$MYUSER $_file_path

    echo "    -- $_file_path created"
}

## creates a _start.sh script to run devilbox with these customized settings
## parameters:  $1 magento version string
function create_start_dbox_script {
    if [ $# -eq 0 ]; then
        echo "Error ${FUNCNAME[0]}: you must provide a magento version parameter"

        exit 1
    fi

    case "$1" in
        2.4* ) start_magento_version=2.4 ;;
        * ) echo "Error ${FUNCNAME[0]}: magento version provided is not available in script yet!!!"; exit 1 ;;
    esac

    _file_name="_start.sh"
    _file_path="$dbox_dir/$_file_name"
    _origin_file_path="to_copy/start_script/$start_magento_version/$_file_name"

    # TODO delete rm line
    rm $_file_path > /dev/null 2>&1

    if [ -f "$_file_path" ]; then
        echo "Error: $_file_path already exists! Delete it first"
        exit 1
    fi

    cp "$_origin_file_path" "$_file_path"
    chown -R $MYUSER:$MYUSER $_file_path
    chmod +x $_file_path

    echo "    -- $_file_path created"
}

function finish_devilbox_preparation_feedback_message {
    echo
    echo
    echo "Finished preparing devilbox enviroment..." 
    echo "for magento version: $1"
    echo
    echo
}

function finish_devilbox_create_project_feedback_message {
    echo
    echo
    echo "Finished creating devilbox project..." 
    echo "project dir: /$1"
    echo "local domain: http://$1.loc"
    echo
    echo
}

function create_install_script {
    echo "create install script"
}