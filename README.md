# ProxmoxBackupClientDocker
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
