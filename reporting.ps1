#To be called from backupscript.ps1


$Errorstrings="error","warning","fail"

$transcript=get-content /root/$now

##Check for error text

$errorlines=$transcript | Select-String -Pattern $Errorstrings


if($env:elastic_host){
    
    @{
      log=$transcript
      status=$status
      errorlines=$errorlines
    }
}
