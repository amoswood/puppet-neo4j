#!/bin/bash

AUTH_ENDPOINT=$1
LOGIN=$2
USER=$3

if [ $# -ne 3 ]
then
  echo "Not enough arguments."
  exit 1
fi

#Test if the service is active yet
curl -XGET --silent --user $LOGIN $AUTH_ENDPOINT/list
if [ $? -ne 0 ]; then
  exit 1
fi

for f in `curl -XGET --silent --user $LOGIN $AUTH_ENDPOINT/list | grep -oE "$USER:[^\"]*"`
do
  curl -XPOST --silent --user $LOGIN -d "user=$f" $AUTH_ENDPOINT/remove-user
done

exit 0
