#!/bin/bash
#IN PROGRESS

installdeps(){
    apt-get install -y curl jq
}

readandcurl() {
    export $(xargs < ./.env)
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
        jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' token.json >> .env
        rm token.json
        return 0;
    else
        cat token.json
        rm token.json
        return -1;
    fi
}

installFiles() {

    echo "\nEnter the frequency with which you'd like to recieve mails: 
    \n(1) every minute
    \n(2) every 15 minutes
    \n(3) every 15 minutes
    \n(3) every 60 minutes"
    read FREQ

    case $FREQ in
        1)
            sed '7s/=.*/*-*-* *:*:00/'
            ;;
        2)
            sed '7s/=.*/=*:0/15/'
            ;;
        3)
            sed '7s/=.*/=*:0/30/'
            ;;
        4)
            sed '7s/=.*/=*:0/60/'
            ;;
    esac

    mkdir -p /var/log/test1/
    touch /var/log/test1/time.log
    touch /var/log/test1/audit.log
    sed '7s/log\/audit/log\/test1/' /etc/audit/auditd.conf

    cp ./src/myWriter.service ./src/myWriter.timer /etc/systemd/system/
    cp ./src/myWriter.sh /usr/bin/

    #specify required rules files here, specified a few sample files here.
    cp /usr/share/doc/auditd/examples/rules/40-local.rules /etc/audit/rules.d/
    augenrules --load 
    service auditd reload
    service auditd start

    printf "SUCCESS!\n"
    printf "Loaded Rules:\n"
    auditctl -l
    systemctl start myWriter.service
    systemctl enable myWriter.service

}

main() {
    #installdeps
    readandcurl
    if [[ $? -eq 0 ]]; then
        installFiles
    else
        echo "\nInstallion stopped."
    fi
}

main
