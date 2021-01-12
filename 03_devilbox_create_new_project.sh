#! /bin/bash

## 
## This script creates devilbox project (dir inside devilbox projects dir and entry in hosts)
##
## parameters:  $1 ($project_name) string defining new project name
## 

if [ $# -eq 0 ]; then
    echo "Error in $0: you must provide a $project_name parameter"

    exit 1
fi

source "$PWD/includes/variables.sh"
project_name=$1


## creates a new directory in devilbox project directory
## external variables:  $dbox_www_dir devilbox projects dir path
##                      $project_name string asked to the user
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

## creates a new hosts entry, needs sudo
## external variables:  $project_name string asked to the user
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

function create_devilbox_project {
    create_project_dir
    create_local_hosts_entry
}


echo "03 ---> creating new devilbox project directories and /etc/hosts entry..."
create_devilbox_project