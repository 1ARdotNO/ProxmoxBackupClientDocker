#install GSUTIL Moved to prescript
#echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y
      

function GCP-Backup{
param(
$bucketname,
$backupdir,
$authfile

)

#create folder
$targetdir="$backupdir"

#import credentials
gcloud auth activate-service-account --key-file=$authfile

#run backup
. gsutil -m rsync -d -r $bucketname $targetdir 
}
GCP-Backup -bucketname gs://$ENV:GCP_BUCKETNAME/ -backupdir $ENV:GCP_BACKUPDIR -authfile $ENV:GCP_AUTHFILE
