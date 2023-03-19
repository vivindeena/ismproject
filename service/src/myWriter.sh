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
    #send this using -data-binary? use -F? to pass as attachment?

    curl --location --request POST 'localhost:3000/send-mail' \
        --header "Authorization: Bearer $token" \
        --header 'Content-Type: application/json' \
        --data-raw '{
        "subject" : "'$SUBJECT'",
            "body" : "'$BODY'"
        }'

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
