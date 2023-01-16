##Script to mount cifs share

#install packages (moved to docker file)
#apt install cifs-utils -y

#create dir
if(test-path /mnt/cifs){}
else {mkdir /mnt/cifs}

"mounting cifs..."
try{
    $cifsconnectionstring="username=$($ENV:CIFS_USER),password=$($ENV:CIFS_PASSWORD),domain=$($ENV:CIFS_DOMAIN),ro"
    # Reinitialize ExitCode before calling external command
    $global:LASTEXITCODE = 0
    mount -t cifs $ENV:CIFS_UNC /mnt/cifs -o $cifsconnectionstring
    if($LASTEXITCODE -ne 0){throw "error"}
}catch{
    $internalerrorflag=$true
    write-error "Error doing cifs fuse mount!"
}


