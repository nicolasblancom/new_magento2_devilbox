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

function create_project_dir {
    _project_dir="$dbox_www_dir/$project_name"

    if [ ! -d "$_project_dir" ]; then
        mkdir -p "$_project_dir/htdocs"
        chown -R $MYUSER:$MYUSER $_project_dir
        
        echo "    -- $_project_dir created"

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
        echo "    -- '$_entry' updated in hosts file"
    fi
}

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

function replaces_env_enable {
    service="$1"
    service_search="#$service"
    service_replace="$service"
    sed -i "s/$service_search/$service_replace/" $_file

    echo "    ++ $service enabled"
}

function replaces_env_disable {
    service=$1
    service_search="$service"
    service_replace="#$service"
    sed -i "s/$service_search/$service_replace/" $_file

    echo "    -- $service disabled"
}

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

    echo "    -- $service"
}

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

function create_install_script {
    echo "create install script"
}