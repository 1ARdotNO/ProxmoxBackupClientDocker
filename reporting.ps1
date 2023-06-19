#To be called from backupscript.ps1


$Errorstrings="error","warning","fail","denied","refused","Errno","is not recognized as a name of a cmdlet, function, script file, or executable program"

$transcript=get-content /root/$now

##Check for error text

$errorlines=$transcript | Select-String -Pattern $Errorstrings
#exclude from error log as a harmless warning. ref. patch notes version 2.4
$errorlines=$errorlines | where {$_ -notlike 'storing login ticket failed: $XDG_RUNTIME_DIR must be set'}



    
    $data=@{
      "@timestamp"=$datetime | get-date -format o
      endtimestamp=$datetimeend | get-date -format o
      name = $ENV:ARCHIVENAME
      log="$transcript"
      status=if($errorlines -like "*warning: file size shrunk while reading*"){"Warning"}
             elseif($errorlines -like "*warning: file size increased while reading*"){"Warning"}
             elseif($errorlines -like "*Warning: Permanently added*"){"OK"} #Allow this as it is not really an error in any way, and naturally occurs on firts run and after redploy containers
             elseif($errorlines){"Fail"}
             else{"OK"}
      errorlines=$errorlines | foreach-object {$_.line}
      retrycount=if($retrycount){$retrycount}else{0}
      backuprepository="$ENV:PBS_REPOSITORY"
    } | convertto-json
if($ENV:ELASTIC_SERVER){
    $dbinfo=@{
        server = $ENV:ELASTIC_SERVER
        #user = $ENV:ELASTIC_USERNAME
        #password = $ENV:ELASTIC_PASSWORD
        #protocol = $ENV:ELASTICPROTOCOL
        index = $ENV:ELASTIC_INDEX
    }
    #if index does not exist create it
    if(Get-Elasticindex @dbinfo ){}
    else{
        New-Elasticindex @dbinfo
    sleep 10
    }
    Add-elasticdata @dbinfo -body $data
    
}

if(($data | convertfrom-json).status -like "Fail"){
    IF(!$ENV:MAXRETRY){$ENV:MAXRETRY=3} #Default to 3 retries if nothing is specified
    IF(!$ENV:RETRY_SLEEP){$ENV:RETRY_SLEEP=600} #Default to 3 retries if nothing is specified
    sleep $ENV:RETRY_SLEEP
    $retrycount+=1
    if($retrycount -le $ENV:MAXRETRY){
        . /backupscript.ps1
    }
}
