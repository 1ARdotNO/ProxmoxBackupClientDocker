cd $ENV:SOURCEDIR

#create directory
if(test-path $ENV:SOURCEDIR){}
else {mkdir $ENV:SOURCEDIR}

java -jar /OpsGenieExportUtil.jar --apiKey $ENV:OPSGENIE_APIKEY --backupPath $ENV:SOURCEDIR
