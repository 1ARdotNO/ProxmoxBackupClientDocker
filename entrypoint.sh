#!/bin/bash



#create cronjob
echo "$CRON . /root/env.sh; /usr/bin/pwsh -File /backupscript.sh" | crontab -
#create env's for cron
printenv | sed 's/^\(.*\)$/export \1/g' > /root/env.sh 
#start cron service
service cron start
while /bin/true; do
  sleep 60
done
