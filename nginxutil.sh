#!/bin/bash
path="/home/hackathon/docker/nginx"

usage()
{
    echo "Usage:"
    echo -e "\tadd --name <name> --type <type> --location <location> --port <port>"
    echo -e "\tedit <name>"
    echo -e "\tlist"
    echo -e "\treload"
    echo -e "\tremove <name>"
}

case $1 in
    add )
        shift
        while [ "$1" != "" ]; do
            case $1 in
                -t | --type )
                    shift
                    type=$1
                    ;;
                -n | --name )
                    shift
                    name=$1
                    ;;
                -l | --location )
                    shift
                    location=$1
                    ;;
                -p | --port )
                    shift
                    port=$1
                    ;;
                * )
                    usage
                    exit 1
                    ;;
            esac
            shift
        done
        
        if [ -z "$type" ] || [ -z "$name" ] || [ -z "$location" ] || [ -z "$port" ]
        then
            usage
            exit 1
        fi
        
        sudo cp -i $path/examples/$type $path/sites-enabled/$name && echo "Copying example file..."
        sudo sed -e "s/{{location}}/$location/; s/{{port}}/$port/" -i $path/sites-enabled/$name && echo "Replacing placeholders..."
        echo "Restarting nginx"
        docker restart nginx && echo "DONE"
        ;;
    edit )
        shift
        echo "Opening $EDITOR..."
        sudo $EDITOR $path/sites-enabled/$1
        ;;
    list )
        echo "Config list:"
        
        array=($(ls -1 $path/sites-enabled -I "*.*"))        
        for config in ${array[@]}; do
            echo -e "\t$config"
        done
        ;;
    reload )
        echo "Restarting nginx..."
        docker restart nginx && echo "DONE"
        ;;
    remove )
        echo "Removing $2..."
        sudo rm $path/sites-enabled/$2 && echo "$2 is GONE!!!"
        ;;
    * )
        usage
        ;;
esac
