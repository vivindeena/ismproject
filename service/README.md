##1 INTRODUCTION
audit rules



##2 Installation
###2.1 Dependencies

Use your package manager to install

`auditd`


Run the installation script.

```
chmod +x install.sh; sudo install.sh;
```
###2.2 Configuration

Configuration, including
audit.rules
email freq
could be edited in the script and in `/etc/audit/audit.conf`.

###3.1 Audit System Reference

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security_guide/app-audit_reference

auditd config
max_log_file
    Specifies the maximum size of a single Audit log file, must be set to make full use of the available space on the partition that holds the Audit log files.
    (must be lesser than max email ttachment size.)

max_log_file_action
    Decides what action is taken once the limit set in max_log_file is reached, should be set to keep_logs to prevent Audit log files from being overwritten.

space_left
    Specifies the amount of free space left on the disk for which an action that is set in the space_left_action parameter is triggered. Must be set to a number that gives the administrator enough time to respond and free up disk space. The space_left value depends on the rate at which the Audit log files are generated. 

space_left_action
    It is recommended to set the space_left_action parameter to email or exec with an appropriate notification method.

####Syscall table

at `/usr/include/asm/unistd_64.h`

####Relevant pre-configured audit.rules


###4 MISC

- test auditctl by `auditctl -m "working?"` 

- A stopped service look like:
`Mar 05 11:19:29 fedora audit[1]: SERVICE_STOP pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=warp-svc comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'`
#IN PROGRESS

