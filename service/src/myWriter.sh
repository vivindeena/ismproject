#!/bin/bash
#runs on ubuntu
#send an Email then
#renaming the instantenous audit.log file - audit.log.$EPOCH; then
#write a new audit log file 

setEmail() {

    export $(xargs < /var/log/test1/time.log)
    export $(xargs < ../.env)

    SUBJECT="AUDIT LOG: $logtime"
    BODY="$(date -d @$logtime)"

    LOGFILE="/var/log/test1/audit.log"
    COUNT=0
    while [ $COUNT -le 5 ]; do
        CODE=$(curl -w '%{http_code}' --stderr my_err_file  -o output\
            --header "Authorization: Bearer $token" \
            --form "subject= $SUBJECT"\
            --form "body= $BODY"\
            --form "upload=@$LOGFILE"
            )
        cat output
        rm output

        if [[ "$CODE" =~ ^2 ]]; then
            break
        else
            ((COUNT++))
            sleep 60
        fi
    done
    if [[ $COUNT -eq 5]]; then
        systemctl stop myService.service
        echo "$(date -d @$logtime): Service Stopped because mails are not sent, check and restart the service with 'systemctl start myService.service'" >>/var/log/test1/log.err
    fi
}

setNewLog() {

    EPOCH=$(date "+%s")
    rename "s/audit.log/audit.log.${EPOCH}/" /var/log/test1/audit.log
    touch /var/log/test1/audit.log
    echo "logtime=$(date "+%s")" > /var/log/test1/time.log

}

main() {
    setEmail
    setNewLog
}

main
