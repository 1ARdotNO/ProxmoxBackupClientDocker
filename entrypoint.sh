#!/bin/bash



#insert cronjob
echo "$CRON /usr/bin/pwsh -File /backupscript.sh" | crontab -

while /bin/true; do
  sleep 60
done
