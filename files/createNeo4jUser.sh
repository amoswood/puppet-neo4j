#!/bin/bash

AUTH_ENDPOINT=$1
LOGIN=$2
USER=$3
PASSWORD=$4
READWRITE=$5

if [ $# -lt 4 ]
then
  echo "Not enough arguments."
  exit 1
fi

#Test if the service is active yet
curl -XGET --silent --user $LOGIN $AUTH_ENDPOINT/list
if [ $? -ne 0 ]; then
  exit 1
fi

USERCOUNT=`curl -XGET --silent --user $LOGIN $AUTH_ENDPOINT/list | grep -oE $USER: | wc -l`

if [ $USERCOUNT -eq 0 ]
then
  if [ $READWRITE -eq 1 ]
  then
    curl -XPOST --silent --user $LOGIN -d "user=$USER:$PASSWORD" $AUTH_ENDPOINT/add-user-rw
  else
    curl -XPOST --silent --user $LOGIN -d "user=$USER:$PASSWORD" $AUTH_ENDPOINT/add-user-ro
  fi
fi
exit 0
