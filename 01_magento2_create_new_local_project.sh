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
## Welcome/instruction message and ask for continue
##
##
##
welcome_continue_create_project





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
   echo -e "\t-p you new project name (will match: project dir, database, local domain with .loc)"
   exit 1
}

while getopts "p:" opt
do
    case "$opt" in
        p ) project_name="$OPTARG" ;;
        ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
    esac
done

# Print helpFunction in case parameters are empty
if [ -z "$project_name" ]
then
   echo
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
./02_devilbox_config_enviroment.sh -m $magento_version

## execute remaining steps only executed when new project is created
./03_devilbox_create_new_project.sh $project_name

echo
echo "OK! Finished creating devilbox project..." 
echo "    -- project dir: /$project_name, local domain: http://$project_name.loc"
echo "    -- run: cd $dbox_dir && ./_start.sh && ./shell.sh"
echo "       you're inside php container, so run: cd $project_name/ && ./install_magento.sh"
echo

mageinstall_create_install_script $magento_version $project_name