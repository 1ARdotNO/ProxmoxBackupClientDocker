#!/bin/bash



#create cronjob
echo "$CRON /usr/bin/pwsh -File /backupscript.ps1" | crontab -
#create env's for cron
pwsh -command "Get-ChildItem env: | Export-CliXml /env-vars.clixml"
#start cron service
service cron start
while /bin/true; do
  sleep 60
done
