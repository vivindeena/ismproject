#!/bin/bash

#runs on ubuntu
#send an Email then
#renaming the instantenous audit.log file - audit.log.$EPOCH; then
#write a new audit log file 

setEmail {

    export $(xargs < /var/log/test1/time.log)
    export $(xargs < ../.env)

    SUBJECT="AUDIT LOG: $logtime"
    BODY="$(date -d @$logtime)"

    LOGFILE="/var/log/test1/audit.log"

    curl --location --request POST "$IP:$PORT/send-mail" \
    --header "Authorization: Bearer $token" \
    --form "subject= $SUBJECT"\
    --form "body= $BODY"\
    --form "upload=@$LOGFILE"

}

setNewLog {

    EPOCH=$(date "+%s")
    rename "s/audit.log/audit.log.${EPOCH}/" /var/log/test1/audit.log
    touch /var/log/test1/audit.log
    echo "logtime=$(date "+%s")" > var/log/test1/time.log

}

main {
    setEmail
    setNewLog
}

main
