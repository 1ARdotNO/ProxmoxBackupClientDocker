#!/bin/bash



#insert cronjob
"$CRON /usr/bin/pwsh /backupscript.sh" > /var/spool/cron/root

while /bin/true; do
  sleep 60
done
