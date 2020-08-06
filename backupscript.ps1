###Backupscript

##DEBUGDATA
$ENV:PBS_PASSWORD > /root/PBS_PASSWORD
$ENV:PBS_REPOSITORY > /root/PBS_REPOSITORY
$ENV:ARCHIVENAME > /root/ARCHIVENAME

##Run pre script
if($ENV:PRESCRIPT){
  write-host "Running Pre-script from $($ENV:PRESCRIPT)"
  . $ENV:PRESCRIPT
}

##Run backupjob

if($ENV:PBS_PASSWORD -and $ENV:PBS_REPOSITORY -and $ENV:ARCHIVENAME){
  #create args
  $backupargs="backup $ENV:ARCHIVENAME.pxar:$ENV:SOURCEDIR"
  if($ENV:ENCRYPTIONKEY){
    $backupargs+=" --keyfile $ENV:ENCRYPTIONKEY"
  }
  #start the backup process
  Start-Process -Args $backupargs -FilePath proxmox-backup-client
}
else {
  write-host "MISSING VARIABLES"
}

##Run post script
if($ENV:POSTSCRIPT){
  write-host "Running Post-script from $($ENV:POSTSCRIPT)"
  . $ENV:POSTSCRIPT
}
