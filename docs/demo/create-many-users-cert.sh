#!/bin/sh

while true ; do
  smonkey create-users.json > create-100-users.json
  curl -s -H Content-Type:application/json --insecure --cert ${2} ${1}/data/user/1.0.0 @create-100-users.json
done

