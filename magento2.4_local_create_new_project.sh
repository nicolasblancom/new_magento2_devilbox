#! /bin/bash

##
## This script downloads and installs a magento 2.4.x instance
## and prepares a local enviroment for it in Devilbox
##

# includes
source "$PWD/includes/variables.sh"
source "$PWD/includes/functions.sh"

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
   echo "Usage: sudo $0 -p project_name -b parameterB"
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


## execute script to config devilbox for magento 2.4
./magento2.4_local_switch.sh

## execute remaining steps only executed when new project is created
create_project_dir

create_local_hosts_entry

create_install_script