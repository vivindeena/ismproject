#!/bin/bash 
#IN PROGRES

installdeps(){
    apt-get install -y curl jq
}
readandcurl() {
    export $(xargs < $LOGDIR/.env)
    echo -n "Enter USERNAME:"
    read USER
    echo "Enter PASSWORD:"
    read -s PSWD 
    CODE=$(curl -w '%{http_code}' -o token.json\
        --location --request POST "$DOMAIN/add" \
        --header 'Content-Type: application/json' \
        --data-raw '{
        "client_username": "'$USER'",
            "password" : "'$PSWD'"
        }')
    if [[ "$CODE" =~ ^2 ]]; then
	cp .env $LOGDIR/.env
        jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' token.json >> $LOGDIR/.env
        rm token.json
        return 0;
    else
        cat token.json
        #rm token.json
        return -1;
    fi
}

installFiles() {

    printf "\nEnter the frequency with which you'd like to recieve mails: 
    \n(1) every minute
    \n(2) every 15 minutes
    \n(3) every 30 minutes
    \n(3) every 60 minutes"
    read FREQ

    mul=0
    case $FREQ in
        1)
            sed '7s/=.*/*-*-* *:*:00/' ./src/myWriter.timer
            mul=60
            ;;
        2)
            sed '7s/=.*/=*:0\/15/' ./src/myWriter.timer
            mul=900
            ;;
        3)
            sed '7s/=.*/=*:0\/30/' ./src/myWriter.timer
            mul=1800
            ;;
        4)
            sed '7s/=.*/=*:0\/60/' ./src/myWriter.timer
            mul=3600
            ;;
    esac

    #################


    LOGDIR="/var/log/test1"
    cp ./time.log $LOGDIR/time.log
    touch $LOGDIR/audit.log

    cp ./src/myWriter.service ./src/myWriter.timer /etc/systemd/system/
    cp ./src/myWriter.sh /usr/bin/

    #specify required rules files here, specified a few sample files here.
    #cp /usr/share/doc/auditd/examples/rules/40-local.rules /etc/audit/rules.d/
    augenrules --load 
    service auditd reload
    service auditd start

    printf "\nSUCCESS!"
    printf "\nLoaded Rules:\n"
    auditctl -l

    echo mul is $mul
    sed -i "1s/mul=.*/mul=$mul/" $LOGDIR/time.log
    cat $LOGDIR/time.log
    systemctl daemon-reload

    systemctl start myWriter.service
    systemctl enable myWriter.service

}

main() {
    mkdir -p /var/log/test1/
    sudo -u vivin mkdir /home/vivin/myWriter/
    ls -al $HOME/myWriter
    sudo -u vivin touch /home/vivin/myWriter/log.txt
    LOGDIR="/var/log/test1"
    cp .env $LOGDIR/.env

    installdeps
    readandcurl
    if [[ $? -eq 0 ]]; then
        installFiles
    else
        printf "\nInstallation stopped."
    fi
    ls -al $HOME/myWriter
}

main
