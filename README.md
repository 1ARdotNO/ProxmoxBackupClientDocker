# ProxmoxBackupClientDocker
![Docker Image CI](https://github.com/OvrAp3x/ProxmoxBackupClientDocker/workflows/Docker%20Image%20CI/badge.svg)
WIP!!! NOT ALL FEATURES ARE IMPLEMENTED
Docker image for running proxmox backup client

Works like this, 

Set ENV's to point to which folder you want backed up and to which pbs server (see my other image for PBS https://github.com/OvrAp3x/ProxmoxBackupDocker )

ENVS:
  -CRON
   cron pattern for how often the job should run
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
      - PBS_PASSWORD=SUPERSECRETPASSWORD
      - PBS_REPOSITORY=backupserverhostname:reponame
      - PBS_FINGERPRINT=25:06:35:f1:a4:ad:c2:84:0b:f9:00:a7:c5:3b:22:cb:72:b0:52:8a:22:3a:27:70:11:d3:9a:3c:a1:e2:32:a4
      - SOURCEDIR=/mnt/gcp/
      - ARCHIVENAME=BACKUPARCHIVENAME

      #Optional General ENV's
      - MAXRETRY=3 #Sets autmoatic retry if the log reports any errors, defaults to 3 if not specified
      #For google cloud backup
      - GCP_BUCKETNAME=name of the bucket to backup
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
      # Set encryption key for encrypted backups!
      - ENCRYPTIONKEY=/backup/root/yourkeyfile.enc #Create keyfile manually and mount the file as a volume into the container
      - PBS_ENCRYPTION_PASSWORD=secret #if the keyfile is password proteced put the password here
      #Logging options
        #Log to elasticsearch
      - ELASTIC_SERVER=elastic
      - ELASTIC_USERNAME=personperson ##elastic credentials
      - ELASTIC_PASSWORD=secret ##elastic credentials
      - ELASTIC_PROTOCOL=http
      - ELASTIC_INDEX=backuplogs
