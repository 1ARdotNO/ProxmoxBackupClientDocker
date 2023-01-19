#create directory structures
mkdir /tmp/overlay
mkdir /tmp/low
mount -t tmpfs tmpfs /tmp/overlay
mkdir /tmp/overlay/up
mkdir /tmp/overlay/work

#get latest backup from repo
$latestbackup=(proxmox-backup-client list --output-format json) | convertfrom-json | where {$_."backup-id" -eq $ENV:ARCHIVENAME}

#mount previous backup
try{
    $date1=(Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($latestbackup.'last-backup')) 
    $lastbackupname="host/$($latestbackup.'backup-id')/$(($date1 | get-date -format u).replace(" ","T"))"
    "Mounting lower layer for overlayfs with proxmox-backup-client..."
    if($ENV:PBS_NAMESPACE){
        proxmox-backup-client mount --ns $ENV:PBS_NAMESPACE --keyfile $ENV:ENCRYPTIONKEY $lastbackupname $(($latestbackup.files | where {$_ -like "*pxar*"}).replace('.didx','')) /tmp/low
    }else{
        proxmox-backup-client mount  --keyfile $ENV:ENCRYPTIONKEY $lastbackupname $(($latestbackup.files | where {$_ -like "*pxar*"}).replace('.didx','')) /tmp/low
    }
}catch {
    $internalerrorflag=$true
    write-error "Error doing proxmox-backup-client mount fuse mount!"
}
if(!$internalerrorflag){
    mkdir $ENV:SOURCEDIR
    try{
        "Mounting overlayfs..."
        mount -t overlay overlay -o lowerdir=/tmp/low/,upperdir=/tmp/overlay/up/,workdir=/tmp/overlay/work/ $ENV:SOURCEDIR
    }catch{
        $internalerrorflag=$true
        write-error "Error doing overlay mount!"
    }
}