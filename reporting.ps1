#To be called from backupscript.ps1


$Errorstrings="error","warning","fail"

$transcript=get-content /root/$now

##Check for error text

$errorlines=$transcript | Select-String -Pattern $Errorstrings


if($env:elastic_host){
    
    $data=@{
      log=$transcript
      status=$status
      errorlines=$errorlines
    } | convertto-json
    dbinfo=@{
        server = "$ENV:elastic_server"
        user = "$ENV:elastic_username"
        password = "$ENV:elastic_password"
        protocol = "$ENV:elastic_protocol"
        index = "$ENV:elastic_index"
    }
    #if index does not exist create it
    if(Get-Elasticindex @dbinfo ){}
    else{
        New-Elasticindex @dbinfo
    sleep 10
    }
    add-elasticdata @dbinfo -body $data
    
}
