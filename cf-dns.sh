#!/bin/bash

set -eu

CF_API_EMAIL=""
CF_API_KEY=""
ZONEID=""

REST=${1:-}
DOMAIN=${2:-}
TYPE=${3:-}
DATA=${4:-127.0.0.1}
TTL="1800"

if [ $REST == "GET" ];
then

content=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records?name=$DOMAIN&type=$TYPE" \
    -H "Authorization: Bearer $CF_API_KEY" \
    -H "Content-Type: application/json" )

echo $content | python3 -c "import json, sys; from pprint import pprint; pprint(json.load(sys.stdin))"
STATE=$(echo $content | jq '.success' | cut -d'"' -f 2)
ERRORMSG=$(echo $content | jq '.errors')
    if [ "$STATE" == "true" ]; then

    echo "--------------GET info for $DOMAIN--------------"


    name=$(echo $content | jq '.result | map(.name) | add' | cut -d'"' -f 2)
    id=$(echo $content | jq '.result | map(.id) | add' | cut -d'"' -f 2)
    rType=$(echo $content | jq '.result | map(.type) | add' | cut -d'"' -f 2)
    data=$(echo $content | jq '.result | map(.content) | add' | cut -d'"' -f 2)
    
    echo "ID="$id
    echo "name="$name
    echo "type="$rType
    echo "data="$data
    echo "success="$STATE
    echo "--------------------------------------------------"
    else
        echo "--------------ERROR !!!--------------"
        echo "Error meesage: $ERRORMSG"
        echo "-------------------------------------"
    fi


# fi
elif [ $REST == "POST" ];
then

content=$(curl -sX POST "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records?name=$DOMAIN&type=$TYPE" \
    -H "Authorization: Bearer $CF_API_KEY" \
    -H "Content-Type: application/json" \
    --data '{"type":"'"$TYPE"'","name":"'"$DOMAIN"'","content":"'"$DATA"'","ttl":"'"$TTL"'","proxied":false}')

echo $content | python3 -c "import json, sys; from pprint import pprint; pprint(json.load(sys.stdin))"
STATE=$(echo $content | jq '.success' | cut -d'"' -f 2)
ERRORMSG=$(echo $content | jq '.errors')
    if [ "$STATE" == "true" ]; then
    echo "--------------$DOMAIN $TYPE record : $DATA ADDED--------------"
    
    name=$(echo $content | jq '.result.name' | cut -d'"' -f 2)
    id=$(echo $content | jq '.result.id' | cut -d'"' -f 2)
    rType=$(echo $content | jq '.result.type' | cut -d'"' -f 2)
    data=$(echo $content | jq '.result.content' | cut -d'"' -f 2)
    
    echo "ID="$id
    echo "name="$name
    echo "type="$rType
    echo "data="$data
    echo "success="$STATE
    echo "--------------------------------------------------------------"
    else
        echo "--------------ERROR !!!--------------"
        echo "Error meesage: $ERRORMSG"
        echo "-------------------------------------"
    fi


# fi

elif [ $REST == "PUT" ];
then
echo "--------------STEP1: Get $DOMAIN DNS_ID--------------"
idcontent=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records?name=$DOMAIN&type=$TYPE" \
    -H "Authorization: Bearer $CF_API_KEY" \
    -H "Content-Type: application/json")
echo $content | python3 -c "import json, sys; from pprint import pprint; pprint(json.load(sys.stdin))"
echo "-----------------------------------------------------"

STATE=$(echo $idcontent | jq '.success' | cut -d'"' -f 2)
ERRORMSG=$(echo $idcontent | jq '.errors')
    if [ "$STATE" == "true" ]; then

    name=$(echo $idcontent | jq '.result | map(.name) | add' | cut -d'"' -f 2)
    id=$(echo $idcontent | jq '.result | map(.id) | add' | cut -d'"' -f 2)
    rType=$(echo $idcontent | jq '.result | map(.type) | add' | cut -d'"' -f 2)
    data=$(echo $idcontent | jq '.result | map(.content) | add' | cut -d'"' -f 2)
    
    echo "ID="$id
    echo "name="$name
    echo "type="$rType
    echo "data="$data
    echo "success="$STATE
    
    
    echo "--------------STEP2: UPDATE $DOMAIN DNS_ID $id--------------"
    content=$(curl -sX PUT "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$id" \
        -H "Authorization: Bearer $CF_API_KEY" \
        -H "Content-Type: application/json" \
        --data '{"type":"'"$TYPE"'","name":"'"$DOMAIN"'","content":"'"$DATA"'","ttl":"'"$TTL"'","proxied":false}') 
    
    echo $content | python3 -c "import json, sys; from pprint import pprint; pprint(json.load(sys.stdin))"
    echo "------------------------------------------------------------"
    STATE=$(echo $content | jq '.success' | cut -d'"' -f 2)
    ERRORMSG=$(echo $content | jq '.errors')
        if [ "$STATE" == "true" ]; then
        echo "--------------$DOMAIN $rType record UPDATED!!!--------------"
        name=$(echo $content | jq '.result.name' | cut -d'"' -f 2)
        id=$(echo $content | jq '.result.id' | cut -d'"' -f 2)
        rType=$(echo $content | jq '.result.type' | cut -d'"' -f 2)
        data=$(echo $content | jq '.result.content' | cut -d'"' -f 2)
        
        echo "ID="$id
        echo "name="$name
        echo "NEW_type="$rType
        echo "NEW_data="$data
        echo "success="$STATE
        echo "------------------------------------------------------------"  
        else
        echo "--------------ERROR !!!--------------"
        echo "Error meesage: $ERRORMSG"
        echo "-------------------------------------"
        fi
    else
    echo "--------------ERROR !!!--------------"
    echo "Error meesage: $ERRORMSG"
    echo "-------------------------------------"
    fi


elif [ $REST == "DELETE" ];
then
echo "--------------STEP1: Get $DOMAIN DNS_ID--------------"
idcontent=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records?name=$DOMAIN&type=$TYPE" \
    -H "Authorization: Bearer $CF_API_KEY" \
    -H "Content-Type: application/json")
echo $content | python3 -c "import json, sys; from pprint import pprint; pprint(json.load(sys.stdin))"
echo "-----------------------------------------------------"

STATE=$(echo $idcontent | jq '.success' | cut -d'"' -f 2)
ERRORMSG=$(echo $idcontent | jq '.errors')
    if [ "$STATE" == "true" ]; then

    name=$(echo $idcontent | jq '.result | map(.name) | add' | cut -d'"' -f 2)
    id=$(echo $idcontent | jq '.result | map(.id) | add' | cut -d'"' -f 2)
    rType=$(echo $idcontent | jq '.result | map(.type) | add' | cut -d'"' -f 2)
    data=$(echo $idcontent | jq '.result | map(.content) | add' | cut -d'"' -f 2)
    
    echo "ID="$id
    echo "name="$name
    echo "type="$rType
    echo "data="$data
    echo "success="$STATE
    
    
    echo "--------------STEP2: DELETE $DOMAIN DNS_ID $id--------------"
    content=$(curl -sX DELETE "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$id" \
        -H "Authorization: Bearer $CF_API_KEY" \
        -H "Content-Type: application/json")
    
    echo $content | python3 -c "import json, sys; from pprint import pprint; pprint(json.load(sys.stdin))"
    echo "------------------------------------------------------------"
    STATE=$(echo $content | jq '.success' | cut -d'"' -f 2)
    ERRORMSG=$(echo $content | jq '.errors')
        if [ "$STATE" == "true" ]; then
        echo "--------------$DOMAIN $rType record DELETED!!!--------------"
        else
        echo "--------------ERROR !!!--------------"
        echo "Error meesage: $ERRORMSG"
        echo "-------------------------------------"
        fi
    else
    echo "--------------ERROR !!!--------------"
    echo "Error meesage: $ERRORMSG"
    echo "-------------------------------------"
    fi

fi