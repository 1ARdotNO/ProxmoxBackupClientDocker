###Backupscript


##Run pre script
if($ENV:PRESCRIPT){
  write-host "Running Pre-script from $($ENV:PRESCRIPT)"
  . $ENV:PRESCRIPT
}

##Run backupjob

proxmox-backup-client backup
