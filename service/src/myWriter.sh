#!/bin/bash
#writes a new audit log file after 
#renaming the instantenous audit.log file - audit.log.$EPOCH;

EPOCH=$(date "+%s")
prename "s/audit.log/audit.log.${EPOCH}/" /var/log/test1/audit.log
touch /var/log/test1/audit.log
echo "$(date "+%s")" >> var/log/test1/time.log

#email stuff under here? if needed?
