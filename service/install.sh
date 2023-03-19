#/bin/bash
#IN PROGRESS

readandcurl() {

    echo "Enter USERNAME:"
    read USER
    echo "Enter PASSWORD:"
    read -s PSWD 
    echo "JWT for $USER:$PSWD:"
    curl --location --request POST 'localhost:3000/add' \
        --header 'Content-Type: application/json' \
        --data-raw '{
        "client_username": "'$USER'",
            "password" : "'$PSWD'"
        }' > token.json

    touch .env
    jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' token.json > .env
    rm token.json

}

installFiles() {

    mkdir -p /var/log/test1/
    touch /var/log/test1/time.log
    touch /var/log/test1/audit.log
    sed '7s/audit/test1/' /etc/audit/auditd.conf

    cp ./src/myWriter.service ./src/myWriter.timer /etc/systemd/system/
    cp ./src/myWriter.sh /usr/bin/

    #specify required rules files here, specified a few sample files here.
    cp /usr/share/doc/auditd/examples/rules/40-local.rules /etc/audit/rules.d/
    augenruleuses --load 
    service auditd reload
    service auditd start

    printf "SUCCESS!\n"
    printf "Loaded Rules:\n"
    auditctl -l
    systemctl start myWriter.service
    systemctl enable myWriter.service

}

main() {
    readandcurl
    installFiles
}

main
