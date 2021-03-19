#To be called from backupscript.ps1


$Errorstrings="error","warning","fail","denied","refused"

$transcript=get-content /root/$now

##Check for error text

$errorlines=$transcript | Select-String -Pattern $Errorstrings


if($ENV:ELASTIC_SERVER){
    
    $data=@{
      "@timestamp"=$datetime | get-date -format o
      name = $ENV:ARCHIVENAME
      log="$transcript"
      status=if($errorlines -like "*warning: file size shrunk while reading*"){"Warning"}
             elseif($errorlines -like "*warning: file size increased while reading*"){"Warning"}
             elseif($errorlines -like "*Warning: Permanently added*"){"OK"} #Allow this as it is not really an error in any way, and naturally occurs on firts run and after redploy containers
             elseif($errorlines){"Fail"}
             else{"OK"}
      errorlines=$errorlines | foreach-object {$_.line}
      retrycount=if($retrycount){$retrycount}else{0}
    } | convertto-json
    $dbinfo=@{
        server = $ENV:ELASTIC_SERVER
        user = $ENV:ELASTIC_USERNAME
        password = $ENV:ELASTIC_PASSWORD
        protocol = $ENV:ELASTICPROTOCOL
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
    $retrycount+=1
    if($retrycount -le $ENV:MAXRETRY){
        . /backupscript.ps1
    }
}
