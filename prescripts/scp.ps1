  
##Script to download file(s) from scp for backup
mkdir $ENV:SCP_TARGET
sshpass -p "$($ENV:SCP_PASSWORD)" scp -o StrictHostKeyChecking=no -r $ENV:SCP_USER@$($ENV:SCP_HOST):$($ENV:SCP_SOURCE) $ENV:SCP_TARGET
