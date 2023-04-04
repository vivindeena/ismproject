#!/bin/bash
LOGDIR=/var/log/test1
    export $(xargs < $LOGDIR/.env)
echo $DOMAIN
echo $token

curl -o $LOGDIR/output\
            --location --request POST "$DOMAIN/add" \
            --header "Authorization: Bearer $token" \
            --form "subject=s"\
            --form "body=b"\
            --form "upload=@$LOGDIR/audit.log"
