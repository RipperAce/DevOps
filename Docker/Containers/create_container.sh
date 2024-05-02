#!/bin/bash

#Read container image name, host port, container port and --env param if any
MESSAGE="$0 --name [image name] --hport [host port] --cport [container port] --env [environment variable]"
if [ $1 = "--help" ] || [ $1 = "-h" ]
then
        echo "$MESSAGE"
        exit 0
fi


if [ $# -gt 6 ] && [ $# -lt 9 ]
then
        if [ $1 = "--name" ] && [ $3 = "--hport" ] && [ $5 = "--cport" ] && [ $7 = "--env" ]
        then
                if [ -z $8 ]
                then
                        docker container run --name $2 --publish $4:$6 --detach $2:latest
                else
                        docker container run --name $2 --publish $4:$6 --detach --env $8 $2:latest
                fi
        else
                echo $MESSAGE
                exit 2
        fi
else
        echo $MESSAGE
        exit 3
fi
