#!/bin/bash



#insert cronjob
echo "$CRON /usr/bin/pwsh -File /backupscript.sh" | crontab -
service cron start
while /bin/true; do
  sleep 60
done
