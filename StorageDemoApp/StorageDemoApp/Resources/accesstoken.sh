#!/bin/bash


set -euo pipefail


key_json_file=$1
scope="$2"
token_sh_file_path="$3"
#key_json_file=$key_json_file|sed 's/%20/ /g'
new_file_name=`echo "$key_json_file" | sed 's/%20/ /g'`

jwt_token=$("${token_sh_file_path}/jwttoken.sh" "$new_file_name" "$scope")


curl -s -X POST https://www.googleapis.com/oauth2/v4/token \
    --data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer' \
    --data-urlencode "assertion=$jwt_token" \
    | jq -r .access_token

