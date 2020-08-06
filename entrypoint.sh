#!/bin/bash



#create cronjob
echo "$CRON . /root/env.sh; /usr/bin/pwsh -File /backupscript.sh" | crontab -
#create env's for cron
pwsh -command "Get-ChildItem env: | Export-CliXml /env-vars.clixml"
#start cron service
service cron start
while /bin/true; do
  sleep 60
done
