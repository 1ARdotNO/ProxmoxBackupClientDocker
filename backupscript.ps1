###Backupscript
$datetime=get-date
$now=$datetime | get-date -Format yyyyMMdd_HHmm
#Start logging
start-transcript -path /root/$now

#Import ENV's
Import-CliXml /env-vars.clixml | % { Set-Item "env:$($_.Name)" $_.Value }

#Check if task is already running
if(test-path /running){
write-output "ERROR:Already running or previous job interrupted"
stop-transcript
. /reporting.ps1
exit
}
else {get-date > /running}

##Run pre script
if($ENV:OVERLAY){
  . /overlayfsmount.ps1
}
if($ENV:CLEANBACKUPDIRBEFORE){
  . /clean-backupdir.ps1
}
if($ENV:PRESCRIPT){
  write-host "Running Pre-script from $($ENV:PRESCRIPT)"
  . $ENV:PRESCRIPT
}
if($ENV:BW_CLIENTID){
  . /bitwarden.ps1
}
if($ENV:PORTWARDEN_VAULTNAME){
  . /portwarden.ps1
}
if($ENV:CIFS_UNC){
  . /cifs.ps1
}
if($ENV:GCP_BUCKETNAME){
  . /googlecloud.ps1
}
if($ENV:SCP_HOST){
  . /scp.ps1
}
if($ENV:GITHUB_TOKEN){
  "START GITHUB BACKUP"
  . /github.ps1
}
if($ENV:ATLASSIANCLOUD_JIRABACKUP){
  "START JIRA BACKUP"
  . /jira-cloud.ps1
}
if($ENV:ATLASSIANCLOUD_CONFLUENCEBACKUP){
  "START CONFLUENCE BACKUP"
  . /confluence-cloud.ps1
}
if($ENV:OPSGENIE_APIKEY){
  "START CONFLUENCE BACKUP"
  . /opsgenie.ps1
}
if($ENV:INSTAGRAM_PROFILES){
  "START INSTAGRAM BACKUP"
  . /instagram.ps1
}


##Run backupjob
if($internalerrorflag){
  write-error "Internal error detected, aborting job!"
}
elseif($ENV:PBS_PASSWORD -and $ENV:PBS_REPOSITORY -and $ENV:ARCHIVENAME){
  #if username set, insert into repository string
  if($ENV:PBS_USERNAME){
    $ENV:PBS_REPOSITORY="$ENV:PBS_USERNAME@$ENV:PBS_REPOSITORY"
  }
  write-host "BACKUP STARTED $(get-date)"
  #create args
  #create 1 archive per item in the sourcefolder, or one global (default)
  if($ENV:ARCHIVEPERITEM){
    $backupargs="backup "
    get-childitem $ENV:SOURCEDIR | foreach-object {
      $backupargs=$backupargs + " " + $($_.name) + ".pxar:" + $($_.fullname)
    }
  }
  elseif($ENV:BACKUPPERITEM){
    get-childitem $ENV:SOURCEDIR | foreach-object -throttlelimit 5 -parallel {
      $backupargs="backup"
      $backupargs=$backupargs + " " + $($_.name) + ".pxar:" + $($_.fullname)
        if($ENV:ENCRYPTIONKEY){
          $backupargs+=" --keyfile $ENV:ENCRYPTIONKEY"
        }
        if($ENV:PBS_NAMESPACE){
          $backupargs+=" --ns $ENV:PBS_NAMESPACE"
        }
        $backupargs+=" --backup-id $($_.name)"
      Start-Process -Wait -Args $backupargs -FilePath proxmox-backup-client -nonewwindow -RedirectStandardOutput "/tmp/output-$($_.name).log" -RedirectStandardError "/tmp/error-$($_.name).log"
      get-content "/tmp/output-$($_.name).log"
      get-content "/tmp/error-$($_.name).log"
    }
  }
  else{
    $backupargs="backup $ENV:ARCHIVENAME.pxar:$ENV:SOURCEDIR"
  }
  if($ENV:ENCRYPTIONKEY){
    $backupargs+=" --keyfile $ENV:ENCRYPTIONKEY"
  }
  if($ENV:PBS_NAMESPACE){
    $backupargs+=" --ns $ENV:PBS_NAMESPACE"
  }
  #start the backup process
  if($ENV:BACKUPPERITEM){}else{
    Start-Process -Wait -Args $backupargs -FilePath proxmox-backup-client -RedirectStandardOutput /tmp/output.log -RedirectStandardError /tmp/error.log -nonewwindow
    #Print log to transcript
    get-content /tmp/output.log
    get-content /tmp/error.log
  }
  write-host "BACKUP COMPLETE $(get-date)"

}
else {
  write-host "MISSING VARIABLES"
}

##Run post script
if($ENV:POSTSCRIPT){
  write-host "Running Post-script from $($ENV:POSTSCRIPT)"
  . $ENV:POSTSCRIPT
}
if($ENV:CIFS_UNC){
  umount /mnt/cifs
}
if($ENV:GITHUB_TOKEN){
  . /post-github.ps1
}
if($ENV:ATLASSIANCLOUD_JIRABACKUP){
  . /post-jira-cloud.ps1
}
if($ENV:ATLASSIANCLOUD_CONFLUENCEBACKUP){
  . /post-confluence-cloud.ps1
}
if($ENV:CLEANBACKUPDIRAFTER){
  . /post-clean-backupdir.ps1
}
if($ENV:OVERLAY){
  . /post-overlayfsmount.ps1
}


#Remove flag to show that task is running
remove-item /running -force
stop-transcript

#Backup end for reporting
$datetimeend=get-date

#Process logs
. /reporting.ps1

