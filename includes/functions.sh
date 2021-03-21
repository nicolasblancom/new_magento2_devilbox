##
##
##
## Functions
##
##
##

# Gives welcome, short explanation, ask for action to continue
function welcome_continue_create_project {
    echo 
    echo "This script needs Devilbox installed in your system. For more information: https://devilbox.readthedocs.io/en/latest/getting-started/install-the-devilbox.html"
    echo
    echo "**IMPORTANT**: this script will delete your devilbox/.env file and the devilbox/cfg/php-ini-<version>/custom.ini file, make sure to backup those"
    echo 
    echo "-- sudo is needed, as the script needs to write in your /etc/hosts file"
    echo "-- the script will make <your-user-home-dir>/www-projects as your devilbox project directory"
    echo 
    echo "Instructions: just copy and paste the commands you are given when the script finishes"
    echo "a 'devilbox/_start.sh' file will be created so you can run containers again the same way"
    echo 
    
    read -p "Are you sure you want to continue? (y/n)" decision

    case "$decision" in
        y ) return 0 ;;
        n ) echo "...canceled by user..."; exit 1 ;;
        * ) echo "...incorrect option..."; exit 1 ;;
    esac
}


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
        echo "Error: .env file already exists!! Delete it first"
        exit 1
    fi

    cp "$dbox_env_file" "$dbox_dir/.env"
    chown -R $MYUSER:$MYUSER "$dbox_dir/.env"

    echo "    -- new .env file created"
}

## Searchs inside the newly created .env file and injects a new line after the last match of the searched string
## parameters:  $1 string to search
##              $2 string to replace
function inject_env_option_after_last_option_match {
    tac $_file | awk '!p && /'"$1"'/{print "'$2'"; p=1} 1' | tac > tmp.txt && mv tmp.txt $_file

    echo "        -- $2"
}

## makes necessary .env replaces depending on magento version
function replaces_env {
    _file="$dbox_dir/.env"
    
    if [ ! -f "$_file" ]; then
        echo "Error: no .env file found"
        exit 1
    fi

    echo "    -- Options injected in .env file:"
    ## php
    inject_env_option_after_last_option_match "PHP_SERVER" $dbox_PHP_SERVER

    ## web server
    inject_env_option_after_last_option_match "HTTPD_SERVER" $dbox_HTTPD_SERVER

    ## database engine
    inject_env_option_after_last_option_match "MYSQL_SERVER" $dbox_MYSQL_SERVER

    ## redis
    inject_env_option_after_last_option_match "REDIS_SERVER" $dbox_REDIS_SERVER

    ## local fylesystem
    inject_env_option_after_last_option_match "HOST_PATH_HTTPD_DATADIR" $dbox_HOST_PATH_HTTPD_DATADIR

    ## disable php modules
    inject_env_option_after_last_option_match "PHP_MODULES_DISABLE" $dbox_PHP_MODULES_DISABLE
}

## creates docker-compose.override.yml to enable additional containers in devilbox
## parameters:  $magento_version magento version string
##              $dbox_www_dir devilbox projects dir path
##              $project_name string asked to the user
function enable_additional_containers {
    # TODO: extract to variables.sh file
    _file_name="docker-compose.override.yml"
    _file_path="$dbox_dir/$_file_name"

    _origin_file_path="to_copy/docker-compose.override/$magento_version_for_docker_compose_override/$_file_name"
    if [ ! -f "$_origin_file_path" ]; then
        echo -e "${T_CRED}Error: $_origin_file_path does not exist${T_CNCOLOR}"
        exit 1
    fi

    # TODO delete rm line
    rm $_file_path > /dev/null 2>&1

    if [ -f "$_file_path" ]; then
        echo -e "${T_CRED}Error: $_file_path already exists! Delete it first${T_CNCOLOR}"
        exit 1
    fi

    cp "$_origin_file_path" "$_file_path"
    chown -R $MYUSER:$MYUSER $_file_path

    echo "    -- $_file_path created"
}

## customizes php.ini by createing custom.ini inside devilbox config php files
## parameters:  $magento_version magento version string
function customize_php_ini {
    _file_name="custom.ini"
    _file_path="$dbox_dir/cfg/php-ini-$php_version_for_ini/$_file_name"
    _origin_file_path="to_copy/php.ini/$php_version_for_ini/custom.ini"

    if [ ! -f "$_origin_file_path" ]; then
        echo -e "${T_CRED}Error: $_origin_file_path does not exist${T_CNCOLOR}"
        exit 1
    fi

    # TODO delete rm line
    rm $_file_path > /dev/null 2>&1

    if [ -f "$_file_path" ]; then
        echo -e "${T_CRED}Error: $_file_path already exists! Delete it first${T_CNCOLOR}"
        exit 1
    fi

    cp "$_origin_file_path" "$_file_path"
    chown -R $MYUSER:$MYUSER $_file_path

    echo "    -- $_file_path created"
}

## creates a _start.sh script to run devilbox with these customized settings
## parameters:  $magento_version magento version string
function create_start_dbox_script {
    _file_name="_start.sh"
    _file_path="$dbox_dir/$_file_name"
    _origin_file_path="to_copy/start_script/$magento_version_for_start_script/$_file_name"

    if [ ! -f "$_origin_file_path" ]; then
        echo -e "${T_CRED}Error: $_origin_file_path does not exist${T_CNCOLOR}"
        exit 1
    fi

    # TODO delete rm line
    rm $_file_path > /dev/null 2>&1

    if [ -f "$_file_path" ]; then
        echo -e "${T_CRED}Error: $_file_path already exists! Delete it first${T_CNCOLOR}"
        exit 1
    fi

    cp "$_origin_file_path" "$_file_path"
    chown -R $MYUSER:$MYUSER $_file_path
    chmod +x $_file_path

    echo "    -- $_file_path created"
}


## Copies install script into devilbox project directories and makes replaces on it
function mageinstall_create_install_script {
    if [ $# -eq 0 ]; then
        echo "Error: You need to give 2 parameters: magento_version project_name"
        exit 1
    fi

    if [ -z "$2" ]; then
        echo "Error: You need to give second parameter project_name"
        exit 1
    fi

    if [ -z "$1" ]; then
        echo "Error: You need to give first parameter magento_version"
        exit 1
    fi

    magento_version=$1
    project_name=$2

    # copy script to project dir (from there we will run installation when entered in container)
    _file_name="install_magento.sh"
    _file_path="$dbox_www_dir/$project_name/$_file_name"
    _origin_file_path="to_copy/install_magento/$magento_version/$_file_name"

    cp "$_origin_file_path" "$_file_path"
    chown -R $MYUSER:$MYUSER $_file_path
    chmod +x $_file_path

    # copy auth.json with composer credential for magento repo in project dir (from 
    # there we have to copy to devilbox user home inside the container)
    _file_name2="auth.json"
    _file_path2="$dbox_www_dir/$project_name/$_file_name2"
    _origin_file_path2="to_copy/install_magento/$magento_version/$_file_name2"

    cp "$_origin_file_path2" "$_file_path2"
    chown -R $MYUSER:$MYUSER $_file_path2

    # replace in script database creation with project_name
    sed -i "s/##project_name##/$project_name/" $_file_path


    # replace in script download magento url with magento_version
    sed -i "s/##magento_version##/$magento_version/" $_file_path
}