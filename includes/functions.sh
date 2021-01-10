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

    echo "    -- $service"

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
    
    echo "    -- $service"

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
    
    echo "    -- $service"

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

function enable_additional_containers {
    _file_name="docker-compose.override.yml"
    _file_path="$dbox_dir/$_file_name"

    # TODO delete rm line
    rm $_file_path > /dev/null 2>&1

    if [ -f "$_file_path" ]; then
        echo "Error: $_file_path already exists! Delete it first"
        exit 1
    fi

    cp "to_copy/$_file_name" "$_file_path"
    chown -R $MYUSER:$MYUSER $_file_path

    echo "    -- $_file_path created"
}

function customize_php_ini {
    _file_name="custom.ini"
    _file_path="$dbox_dir/cfg/php-ini-7.4/$_file_name"

    # TODO delete rm line
    rm $_file_path > /dev/null 2>&1

    if [ -f "$_file_path" ]; then
        echo "Error: $_file_path already exists! Delete it first"
        exit 1
    fi

    cp "to_copy/$_file_name" "$_file_path"
    chown -R $MYUSER:$MYUSER $_file_path

    echo "    -- $_file_path created"
}

function create_start_dbox_script {
    _file_name="_start.sh"
    _file_path="$dbox_dir/$_file_name"

    # TODO delete rm line
    rm $_file_path > /dev/null 2>&1

    if [ -f "$_file_path" ]; then
        echo "Error: $_file_path already exists! Delete it first"
        exit 1
    fi

    cp "to_copy/$_file_name" "$_file_path"
    chown -R $MYUSER:$MYUSER $_file_path
    chmod +x $_file_path

    echo "    -- $_file_path created"
}

