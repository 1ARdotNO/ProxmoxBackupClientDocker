###Backupscript


##Run pre script
if($ENV:PRESCRIPT){
  write-host "Running Pre-script from $($ENV:PRESCRIPT)"
  . $ENV:PRESCRIPT
}

##Run backupjob

if($ENV:PBS_PASSWORD -and $ENV:PBS_REPOSITORY -and $ENV:ARCHIVENAME){
  proxmox-backup-client backup $ENV:ARCHIVENAME.pxar:/root
}
else {
  write-host "MISSING VARIABLES"
}
