#create directory structures

if($ENV:OVERLAY_TMPFS -eq "false"){
    if(!$ENV:OVERLAY_PATH){
        $ENV:OVERLAY_PATH="/OVERLAY"
    }
    mkdir $ENV:OVERLAY_PATH/low
    mkdir $ENV:OVERLAY_PATH/overlay
    mkdir $ENV:OVERLAY_PATH/overlay/up
    mkdir $ENV:OVERLAY_PATH/overlay/work
}else{
    mkdir /tmp/overlay
    mkdir /tmp/low
    mount -t tmpfs tmpfs /tmp/overlay
    mkdir /tmp/overlay/up
    mkdir /tmp/overlay/work
    $ENV:OVERLAY_PATH="/tmp"
}

#get latest backup from repo
if($ENV:PBS_NAMESPACE){
    $latestbackup=(proxmox-backup-client list --ns $ENV:PBS_NAMESPACE --output-format json) | convertfrom-json | where {$_."backup-id" -eq $ENV:ARCHIVENAME}
}else{
    $latestbackup=(proxmox-backup-client list --output-format json) | convertfrom-json | where {$_."backup-id" -eq $ENV:ARCHIVENAME}
}

#mount previous backup
try{
    $date1=(Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($latestbackup.'last-backup')) 
    $lastbackupname="host/$($latestbackup.'backup-id')/$(($date1 | get-date -format u).replace(" ","T"))"
    "Mounting lower layer for overlayfs with proxmox-backup-client..."
    if($ENV:PBS_NAMESPACE){
        proxmox-backup-client mount --ns $ENV:PBS_NAMESPACE --keyfile $ENV:ENCRYPTIONKEY $lastbackupname $(($latestbackup.files | where {$_ -like "*pxar*"}).replace('.didx','')) $ENV:OVERLAY_PATH/low
    }else{
        proxmox-backup-client mount  --keyfile $ENV:ENCRYPTIONKEY $lastbackupname $(($latestbackup.files | where {$_ -like "*pxar*"}).replace('.didx','')) $ENV:OVERLAY_PATH/low
    }
}catch {
    $internalerrorflag=$true
    write-error "Error doing proxmox-backup-client mount fuse mount!"
}
if(!$internalerrorflag){
    mkdir $ENV:SOURCEDIR
    try{
        "Mounting overlayfs..."
        $mountstring="lowerdir=/tmp/low/,upperdir=$ENV:OVERLAY_PATH/overlay/up/,workdir=$ENV:OVERLAY_PATH/overlay/work/"
        mount -t overlay overlay $ENV:SOURCEDIR -o $mountstring 
    }catch{
        $internalerrorflag=$true
        write-error "Error doing overlay mount!"
    }
}