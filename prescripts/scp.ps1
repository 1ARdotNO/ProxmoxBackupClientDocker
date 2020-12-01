  
##Script to download file(s) from scp for backup

sshpass -p $ENV:SCP_PASSWORD scp -r $ENV:SCP_USER@$ENV:SCP_HOST:$ENV:SCP_SOURCE $ENV:SCP_TARGET
