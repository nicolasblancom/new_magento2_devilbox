#! /bin/bash

##
## This script first prepares Devilbox enviroment for a particular magento version (reusing another script for this),
## then creates new dirs and files for a new project (reusing another script for this)
## and creates a required by parameter magento install script inside this new project, so you can enter php 
## container and run it for a full magento required version install and config
##
## in help_function you can see required parameters
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

# Ask for magento version to install
select versions in 2.4.1 "Enter another version" ;
do
    case "$versions" in
        2.4.1)
            magento_version=2.4.1
            break
            ;;
        Enter*)
            read -p "Enter manually a version number: " magento_version
            break
            ;;
    esac
done

# TODO: check ilegal version

## execute script to config devilbox for magento 2.4
./magento2.4_local_switch.sh -m $magento_version

## execute remaining steps only executed when new project is created
./create_devilbox_project.sh $project_name

create_install_script