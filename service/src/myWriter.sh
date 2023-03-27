#!/bin/bash
#runs on ubuntu
#send an Email then
#renaming the instantenous audit.log file - audit.log.$EPOCH; then
#write a new audit log file 

setEmail() {
    LOGDIR="/var/log/test1"

    export $(xargs < $LOGDIR/time.log)
    export $(xargs < ../.env)

    SUBJECT="AUDIT LOG: $startTime to: $endTime"
    BODY="$(date -d @$startTime)"

    LOGFILE="/var/log/test1/audit.log"
    COUNT=0
    #while [ $COUNT -le 5 ]; do
        CODE=$(curl -w '%{http_code}' --stderr my_err_file  -o output\
            --header "Authorization: Bearer $token" \
            --form "subject= $SUBJECT"\
            --form "body= $BODY"\
            --form "upload=@$LOGFILE"
            )
        cat output
        rm output
        :'
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
    '
}

setNewLog() {

    LOGDIR="/var/log/test1"

    export $(xargs < $LOGDIR/time.log)

    echo "before"
    echo $mul
    echo $startTime
    echo $endTime
    ausearch -ts $(date -d @$startTime +'%m/%d/%Y %H:%M:%S') -te $(date -d @$endTime +'%m/%d/%Y %H:%M:%S') -m all -i | tee $LOGDIR/audit.log

    startTime=$(($endTime + 1))
    endTime=$(($startTime+$mul))

    echo "after"
    echo $mul
    echo $startTime
    echo $endTime
    
    sed -i "s/startTime=.*/startTime=$startTime/g" $LOGDIR/time.log
    sed -i "s/endTime=.*/endTime=$endTime/g" $LOGDIR/time.log

}

main() {
    setEmail
    setNewLog
}

main
