#/bin/bash
#IN PROGRESS

main() {
    mkdir -p /var/log/test1/
    touch /var/log/test1/time.log
    touch /var/log/test1/audit.log

    cp ./src/myWriter.service ./src/myWriter.timer /etc/systemd/system/
    cp ./src/myWriter.sh /usr/bin/

    #specify required rules files here, specified a few sample files here.
    cp /usr/share/audit/sample-rules/44-installers.rules /etc/audit/rules.d/
    augenrules --load 
    service auditd reload
    service auditd start
    
    printf "SUCCESS!\n"
    printf "Loaded Rules:\n"
    auditctl -l
    systemctl start myWriter.service
    systemctl enable myWriter.service
}
