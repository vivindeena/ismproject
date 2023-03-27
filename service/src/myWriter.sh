#!/bin/bash
#runs on ubuntu
#send an Email then
#renaming the instantenous audit.log file - audit.log.$EPOCH; then
#write a new audit log file 

setEmail() {
    LOGDIR="/var/log/test1"

    export $(xargs < $LOGDIR/time.log)
    export $(xargs < $LOGDIR/.env)

    SUBJECT="AUDIT LOG: $startTime to: $endTime"
    BODY="$(date -d @$startTime)"

    LOGFILE="/var/log/test1/audit.log"
    echo $DOMAIN | tee -a $LOGDIR/params.log
    echo $token | tee -a $LOGDIR/params.log
    echo $SUBJECT | tee -a $LOGDIR/params.log
    echo $BODY | tee -a $LOGDIR/params.log
    echo $LOGFILE | tee -a $LOGDIR/params.log
            
	curl -w '%{http_code}' --stderr $LOGDIR/my_err_file  -o $LOGDIR/output\
            --location --request POST "$DOMAIN/add" \
            --header "Authorization: Bearer $token" \
            --form "subject= $SUBJECT"\
            --form "body= $BODY"\
            --form "upload=@$LOGFILE"
	
}

setNewLog() {

    LOGDIR="/var/log/test1"

    export $(xargs < $LOGDIR/time.log)

    echo "before"
    echo $mul
    echo $startTime
    echo $endTime
    ausearch -ts $(date -d @$startTime +'%d/%m/%y %H:%M:%S') -te $(date -d @$endTime +'%d/%m/%y %H:%M:%S') -m all -i | tee $LOGDIR/audit.log

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
