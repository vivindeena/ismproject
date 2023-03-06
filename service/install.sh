#/bin/bash
#IN PROGRESS

main() {
    #specify required rules files here, specified a few sample files here.
    cp /usr/share/audit/sample-rules/44-installers.rules /etc/audit/rules.d/
    augenrules --load 

    cp ./test/test1.service /etc/systemd/system

    printf "SUCCESS!\n"
    printf "Loaded Rules:\n"
    auditctl -l
    systemctl start test1.service
    systemctl enable test1.service

    mkdir /var/log/test1/
    touch /var/log/test1/time.log
}
