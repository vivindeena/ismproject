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

    LOGFILE="/home/vivin/myWriter/log.txt"
    echo $DOMAIN | tee -a $LOGDIR/params.log
    echo $token | tee -a $LOGDIR/params.log
    echo $SUBJECT | tee -a $LOGDIR/params.log
    echo $BODY | tee -a $LOGDIR/params.log
    echo $LOGFILE | tee -a $LOGDIR/params.log
            
	curl -w '%{http_code}' --stderr $LOGDIR/my_err_file  -o $LOGDIR/output\
            --location --request POST "$DOMAIN/send-mail" \
            --header "Authorization: Bearer $token" \
            --form "subject= $SUBJECT"\
            --form "body= $BODY"\
            --form "upload=@$LOGFILE"
	
}

setNewLog() {

    LOGFILE="/home/vivin/myWriter/log.txt"
    LOGDIR="/var/log/test1"

    export $(xargs < $LOGDIR/time.log)

    startTime=$(($(date +%s)-$mul))
    endTime=$(date +%s)

    echo "currently"
    echo $mul
    echo $startTime
    echo $endTime
    echo $(date -d @$startTime)
    echo $(date -d @$endTime)
    ausearch -ts $(date -d @$startTime +'%d/%m/%y %H:%M:%S') -te $(date -d @$endTime +'%d/%m/%y %H:%M:%S') -m all -i | tee $LOGFILE

    echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    echo "ausearch -ts $(date -d @$startTime +'%d/%m/%y %H:%M:%S') -te $(date -d @$endTime +'%d/%m/%y %H:%M:%S') -m all -i | tee $LOGFILE"
    echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
}

main() {
    setNewLog
    setEmail
}

main
