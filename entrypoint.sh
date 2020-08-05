#!/bin/bash



#insert cronjob
"$CRON /bin/bash /backupscript.sh" > /var/spool/cron/root
top
while /bin/true; do
  sleep 60
done
