# local user data

# TODO: ask for this info if not already set in this script
MYUSER="nicolasblancom"
MYSUSER_CHOWN=$MYUSER
MYUSER_HOME_DIR="/home/$MYUSER"

# devilbox and its www projects dir

dbox_dir="$MYUSER_HOME_DIR/devilbox"
dbox_www_dir="$MYUSER_HOME_DIR/www-projects" # TODO remove it
dbox_env_file="$dbox_dir/env-example"

# default devilbox enviroment variables for magento 2.4.1
dbox_PHP_SERVER="PHP_SERVER=7.4"
dbox_HTTPD_SERVER="HTTPD_SERVER=apache-2.4"
dbox_MYSQL_SERVER="MYSQL_SERVER=mysql-8.0"
dbox_PGSQL_SERVER=12.4 # not used
dbox_REDIS_SERVER="REDIS_SERVER=5.0"
dbox_MEMCD_SERVER=1.6 # not used
dbox_MONGO_SERVER=4.4 # not used

dbox_HOST_PATH_HTTPD_DATADIR="HOST_PATH_HTTPD_DATADIR=../www-projects"
dbox_PHP_MODULES_DISABLE="PHP_MODULES_DISABLE=oci8,PDO_OCI,pdo_sqlsrv,sqlsrv,rdkafka,swoole,psr"

# default magento variables
magento_version_default=2.4.1 # fallback version if user does not provide it as parameter

# Colors for console output
# Usage example: echo -e "I ${C_RED}love${C_NC} Stack Overflow"
T_CRED='\033[0;31m'
T_CGREEN='\033[0;32m'
T_CNCOLOR='\033[0m' # No Color