#!/bin/bash

export HOST="http://localhost:8774/v1.1/"

function nova_login {
    output=$(curl -i -H "X-Auth-User: $1" -H "X-Auth-Key: $2" $HOST | sed -n '/Token/p')
    token=`echo $output | awk -F": " '{print $2}'`
    export TOKEN=$token
    echo "TOKEN = $TOKEN"
    export ENC="json"
}

function nova_accept {
    export ENC="$1"
}

function list_images {
    curl -H "X-Auth-Token: $TOKEN" -H"ACCEPT: application/$ENC" $HOST/images/detail | python -mjson.tool
}

function list_flavors {
    curl -H "X-Auth-Token: $TOKEN" -H"ACCEPT: application/$ENC" $HOST/flavors/detail | python -mjson.tool
}

function list_servers {
    curl -H "X-Auth-Token: $TOKEN" -H"ACCEPT: application/$ENC" $HOST/servers/detail | python -mjson.tool
}

function list_server {
    curl -H "X-Auth-Token: $TOKEN" -H"ACCEPT: application/$ENC" $HOST/servers/$1 | python -mjson.tool
}

function create_server {
    JSON_DATA='{"server":{"name":"'$1'","flavorRef":"'$HOST'flavors/'$2'", "imageRef":"'$HOST'images/'$3'"}}'
    curl -H "X-Auth-Token: $TOKEN" -H"ACCEPT: application/$ENC" -H"Content-Type: application/json" -d"$JSON_DATA" $HOST/servers | python -mjson.tool
}

function delete_server {
    curl -X DELETE -H "X-Auth-Token: $TOKEN" -H"ACCEPT: application/$ENC" $HOST/servers/$1
}
