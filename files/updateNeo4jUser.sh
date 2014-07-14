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
READWRITESTRING="RO"

if [ $READWRITE -eq 1 ]
then
  READWRITESTRING="RW"
fi

if [ $USERCOUNT -gt 1 ]
then
  removeNeo4jUser $AUTH_ENDPOINT $LOGIN $USER
  createNeo4jUser $AUTH_ENDPOINT $LOGIN $USER $PASSWORD $READWRITE
else
  USER_STRING=`curl -XGET --silent --user $LOGIN $AUTH_ENDPOINT/list | grep -oE "$USER:[^,}]*"`
  if [ "$USER_STRING" != "$USER:$PASSWORD\":\"$READWRITESTRING\"" ]
  then
    removeNeo4jUser $AUTH_ENDPOINT $LOGIN $USER
    createNeo4jUser $AUTH_ENDPOINT $LOGIN $USER $PASSWORD $READWRITE
  fi
fi
exit 0
