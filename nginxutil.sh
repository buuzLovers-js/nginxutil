#!/usr/bin/env bash
NGINX_ROOT="/home/hackathon/docker/nginx"
NGINX_RESTART_CMD="docker restart nginx"

usage()
{
    echo "nginxutil v0.1 by buuzlovers team"
    echo "Usage:"
    echo -e "\tadd <name> <type> <key=value...>"
    echo -e "\t\tGenerate a new config"

    echo -e "\tvars <type>"
    echo -e "\t\tShow all variables in <type> config"

    echo -e "\ttypes"
    echo -e "\t\tShow available templates"

    echo -e "\tedit <name>"
    echo -e "\t\tEdit a config with default editor ($EDITOR)"

    echo -e "\tlist"
    echo -e "\t\tList active configs"

    echo -e "\treload"
    echo -e "\t\tRestart NGINX"

    echo -e "\tremove <name>"
    echo -e "\t\tRemove a config"

    echo -e "\thelp"
    echo -e "\t\tShow usage"

}

restartNginx()
{
    echo "Restarting NGINX"
    eval "$NGINX_RESTART_CMD" && echo "Complete!"
}

case $1 in
    add )
        shift
        name=$1
        shift
        type=$1
        shift

        if [ ! -f $NGINX_ROOT/templates/$type.example ]; then
            echo "Config example \"$type\" was not found in $NGINX_ROOT/templates/."
            exit
        fi

        echo "Copying example file..."
        cp -i $NGINX_ROOT/templates/$type.example $NGINX_ROOT/sites-enabled/$name.conf

        echo "Replacing placeholders..."
        rules=""
        while [ "$1" != "" ]; do
            values=($(echo $1 | tr '=' "\n")) # Split "key=value" into array (key, value)
            escapedValue=$(echo ${values[1]} | sed 's/\//\\\//g')
            rules="${rules}s/{{${values[0]}}}/$escapedValue/g;" # Append new rule to "rules" variable
            shift
        done

        rules="${rules}s/{{name}}/$name/g" # Append {{name}} replacer to the end
        echo "$rules"
        sed -z $rules -i $NGINX_ROOT/sites-enabled/$name.conf
        
        if [ -z "$type" ] || [ -z "$name" ]
        then
            usage
            exit 1
        fi

        restartNginx
        ;;
    vars )
        shift
        type=$1

        if [ ! -f $NGINX_ROOT/templates/$type.example ]; then
            echo "Config example \"$type\" was not found in $NGINX_ROOT/templates/."
            exit
        fi

        echo "Variables in \"$type\":"
        cat $NGINX_ROOT/templates/$type.example | grep -oP "{{.+}}"
        ;;
    types )
        echo "Available templates:"
        ls $NGINX_ROOT/templates/ | sed "s/.example//"
        ;;
    edit )
        shift
        echo "Opening $EDITOR..."
        $EDITOR $NGINX_ROOT/sites-enabled/$1
        restartNginx
        ;;
    list )
        echo "Config list:"
        
        array=($(ls -1 $NGINX_ROOT/sites-enabled -I "*.*"))        
        for config in ${array[@]}; do
            echo -e "\t$config"
        done
        ;;
    reload )
        restartNginx
        ;;
    remove )
        echo "Removing $2..."
        rm $NGINX_ROOT/sites-enabled/$2 && echo "$2 is GONE!!!"
        restartNginx
        ;;
    * )
        usage
        ;;
esac
