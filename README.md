# ProxmoxBackupClientDocker
![Docker Image CI](https://github.com/OvrAp3x/ProxmoxBackupClientDocker/workflows/Docker%20Image%20CI/badge.svg)
[![PSScriptAnalyzer](https://github.com/OvrAp3x/ProxmoxBackupClientDocker/actions/workflows/powershell-analysis.yml/badge.svg)](https://github.com/OvrAp3x/ProxmoxBackupClientDocker/actions/workflows/powershell-analysis.yml)
WIP!!! NOT ALL FEATURES ARE IMPLEMENTED
Docker image for running proxmox backup client

Works like this, 

Set ENV's to point to which folder you want backed up and to which pbs server (see my other image for PBS https://github.com/OvrAp3x/ProxmoxBackupDocker )

ENVS:
  -CRON
   cron pattern for how often the job should run
   If CRON is not set, the container will launch the backupjob immediatly take care to not set the restart policy to "always" or "unless stopped, otherwise the container will loop forever
  -SOURCEDIR
   Source folder for the files
  -PRESCRIPT
   path to script to run before the backup
   (plan for included prescripts for a few providers, ie. GCP storage, sshfs, smb)
  -POSTSCRIPT
    path to script to run a job after the backup is complete, to do some cleanup etc.

##TBD
Predefined prescripts should have ENV's to define args, authentication, path etc.

udpate


## ENVIROMENT VARIABLES
    #General REQUIRED ENV's
      - TZ=Europe/Oslo
      - CRON=10 5 * * *
      - PBS_USERNAME=root@pam #username for ypur pbs login, must be formatted like user@pam/user@pbs default root@pam
      - PBS_PASSWORD=SUPERSECRETPASSWORD
      - PBS_REPOSITORY=backupserverhostname:reponame
      - PBS_FINGERPRINT=25:06:35:f1:a4:ad:c2:84:0b:f9:00:a7:c5:3b:22:cb:72:b0:52:8a:22:3a:27:70:11:d3:9a:3c:a1:e2:32:a4
      - SOURCEDIR=/mnt/gcp/
      - ARCHIVENAME=BACKUPARCHIVENAME

      #Optional General ENV's
      - PBS_NAMESPACE=mynamespace/subnamespace/lowestlevelnamespace # select what namespace to use, default is 'root' (no namespace) only for PBS version 2.x and up.
      - OVERLAY=false # enables and overlay that uses the previous backup as a read only lower layer for the new backup, useful for Rsync or gcp rsync backups. default false. (will increase backup times, but will reduce the need for local storage in the backupworkers)
      - OVERLAY_TMPFS=true # The overlay will use tmpfs by default, might need a lot of memory/swap if you have a large dataset/lots of changes in your dataset. if set to false, another caching location must be defined in OVERLAY_PATH
      - OVERLAY_PATH=/OVERLAY # path for overlay if not using tmpfs, default is /OVERLAY
      - MAXRETRY=3 #Sets autmoatic retry if the log reports any errors, defaults to 3 if not specified
      - RETRY_SLEEP=600 #sets delay before retying again default to 600 seconds
      - CLEANBACKUPDIRBEFORE=false #automatically deletes all files from the backup directory before process start
      - CLEANBACKUPDIRAFTER=false #automatically deletes all files from the backup directory after process run
      - ARCHIVEPERITEM=false #automatically create 1 archive in the backup per folder in the source directory
      - HEALTHCHECKSURL=https://hc-ping.com/xxxxxxxxxxxx #disabled by default, put a healthchecks.io endpoint here or any other similar endpoint you want pinged with a "GET" when the job is successfull
      #Bitwarden
      - BW_CLIENTID=87asdhj1 #You API client ID
      - BW_CLIENTSECRET=secretsecretsecret #Your API secret
      - BW_PASSWORD=secretsecretsecretpassword #Your BW Password
      - BW_SERVER=https://yourbitwardenserver.yourdomain.com #optional, with custom server set the url here
      #Portwarden - Bitwarden vault backup tool
      - PORTWARDEN_VAULTNAME=nameofvaultfile.portwarden #Some descriptive name of your vault.
      - PORTWARDEN_PASSPHRASE=yoursecretpassphrase #Create a passphrase for the backup of your bitwarden vault. you NEED this to be able to restore, so choose something you will remember, or keep it in a safe place!
      #For google cloud backup
      - GCP_BUCKETNAME=name of the bucket to backup
      - GCP_BUCKETPATHTIMESTAMP=yyyy-MM-dd #format to use for timestamped fodler inside the bucket ie. bucketname/2023-10-19
      - GCP_BACKUPDIR=/mnt/gcp/ #should match SOURCEDIR
      - GCP_AUTHFILE=/pathtogcp auth file .json
      #For CIFS share as source of backup
      - CIFS_UNC=//server/share/folder/ #should match SOURCEDIR
      - CIFS_USER=backupservice
      - CIFS_PASSWORD=rsecretsecretcifsuserpassword
      - CIFS_DOMAIN=domain
      #SCP file copy backup, copy files from a ssh location and include in backup. ie. for backing up firewall configs etc. (unifi/pfesense)
      - SCP_SOURCE=/cf/conf/backup/ #For pfsense
      - SCP_TARGET=/mnt/scp
      - SCP_HOST=hostname
      - SCP_USER=backupuser
      - SCP_PASSWORD=secret
      #Github repository backup
      - GITHUB_USERNAME=johnwilliams
      - GITHUB_TOKEN=supersecretpersonalaccesstoken
      - GITHUB_ORG=organisation-name #optional, if set includes all repo's in org that your account has access to
      - GITHUB_ORG_REPO_TYPE=All  #optional, options are all,private,public, defaults to all
      - GITHUB_ORG_EXCLUDE_REPOS=reponame #optional, to exclude a repo from org level backup
      - GITHUB_INCLUDE_WIKI=yes #optional defaults to yes, set to no to exclude wiki's
      - GITHUB_INCLUDE_ISSUES=yes #optional defaults to yes, set to no to exclude issues
      - GITHUB_REPOS=repo1,repo2 # optional, use if only backing up specific repo's and org is not set
      #Atlassian cloud backup
      - ATLASSIANCLOUD_TOKEN=yourapitoken
      - ATLASSIANCLOUD_USERNAME=yourusername #emailaddress
      - ATLASSIANCLOUD_ACCOUNT=yourcompany # Atlassian subdomain i.e. whateverproceeds.atlassian.net
      - ATLASSIANCLOUD_JIRABACKUP=yes #to enable jira backup
      - ATLASSIANCLOUD_JIRA_ATTACHMENTS=true #include attachements in backup, defaults to true
      - ATLASSIANCLOUD_CONFLUENCEBACKUP=yes #to enable confluence backup
      - ATLASSIANCLOUD_CONFLUENCE_ATTACHMENTS=true #include attachements in backup, defaults to true
      - OPSGENIE_APIKEY=youropsgenieapikey #to backup opsgenie
      #Instagram profile backup
      - INSTAGRAM_PROFILES=profile1 profile2
      - INSTAGRAM_LOGIN=yourinstagramusername
      - INSTAGRAM_PASSWORD=yourinstagrampassword
      # Set encryption key for encrypted backups!
      - ENCRYPTIONKEY=/backup/root/yourkeyfile.enc #Create keyfile manually and mount the file as a volume into the container
      - PBS_ENCRYPTION_PASSWORD=secret #if the keyfile is password proteced put the password here
      #Logging options
        #Log to elasticsearch
      - ELASTIC_SERVER=elastic
      - ELASTICUSER=personperson ##elastic credentials
      - ELASTICPASSWORD=secret ##elastic credentials
      - ELASTICIGNORECERT=true
      - ELASTICHTTPS=true
      - ELASTIC_INDEX=backuplogs
 
-
