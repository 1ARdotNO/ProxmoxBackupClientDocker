##Script to mount cifs share

#install packages
apt install cifs-utils -y

#create dir
if(test-path /mnt/cifs){}
else {mkdir /mnt/cifs}

mount -t cifs $ENV:CIFS_UNC /mnt/cifs -o username=$ENV:CIFS_USER,password=$ENV:CIFS_PASSWORD,domain=$ENV:CIFS_DOMAIN,ro

