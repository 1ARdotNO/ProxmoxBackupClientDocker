#!/bin/bash


#create env's for cron
pwsh -command "Get-ChildItem env: | Export-CliXml /env-vars.clixml"

#if CRON not set, trigger job immediatly then exit the container
if [ -z ${CRON} ]
then 
#create cronjob
echo "$CRON /usr/bin/pwsh -File /backupscript.ps1" | crontab -
#start cron service
service cron start
while /bin/true; do
  sleep 60
done
else
pwsh /backupscript.ps1
fi


