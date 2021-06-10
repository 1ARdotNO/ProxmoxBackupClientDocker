
$account     = $ENV:ATLASSIANCLOUD_ACCOUNT # Atlassian subdomain i.e. whateverproceeds.atlassian.net
$username    = $ENV:ATLASSIANCLOUD_USERNAME # username with domain something@domain.com
$token    = $ENV:ATLASSIANCLOUD_TOKEN # Token created from product https://confluence.atlassian.com/cloud/api-tokens-938839638.html
$destination = $ENV:SOURCEDIR # Location on server where script is run to dump the backup zip file.
$attachments = $ENV:ATLASSIANCLOUD_CONFLUENCE_ATTACHMENTS # Tells the script whether or not to pull down the attachments as well
$cloud     = 'true' # Tells the script whether to export the backup for Cloud or Server
$today       = Get-Date -format yyyyMMdd-hhm
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

if(!(Test-Path -path $destination)){
write-host "Folder is not present, creating folder"
mkdir $destination #Make the path and folder is not present
}
else{
write-host "Path is already present"
}

#Convert credentials to base64 for REST API header
function ConvertTo-Base64($string) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($string);
    $encoded = [System.Convert]::ToBase64String($bytes);
    return $encoded;
    }

    $b64 = ConvertTo-Base64($username + ":" + $token);
    $auth = $b64;

$string = "cbAttachments:true, exportToCloud:true"
$stringbinary = [system.Text.Encoding]::Default.GetBytes($String) | %{[System.Convert]::ToString($_,2).PadLeft(8,'0') }

$body = @{
          cbAttachments=$attachments
          exportToCloud=$cloud
         }
$bodyjson = $body | ConvertTo-Json

if ($PSVersionTable.PSVersion.Major -lt 4) {
    throw "Script requires at least PowerShell version 4. Get it here: https://www.microsoft.com/en-us/download/details.aspx?id=40855"
}

# Create header for authentication
    [string]$ContentType = "application/json"
    [string]$URI = "https://$account.atlassian.net/wiki/rest/obm/1.0/runbackup"

    #Create Header
        $header = @{
                "Authorization" = "Basic "+$auth
                "Content-Type"="application/json"
                    }

# Request backup
try {
        $InitiateBackup = Invoke-RestMethod -Method Post -Headers $header -Uri $URI -ContentType $ContentType -Body $bodyjson -Verbose | ConvertTo-Json -Compress | Out-Null
} catch {
        $InitiateBackup = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($InitiateBackup)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
}

$responseBody

$GetBackupID = Invoke-WebRequest -Method Get -Headers $header https://$account.atlassian.net/wiki/rest/obm/1.0/getprogress
$BackupStatus = convertfrom-json $GetBackupID.content
$BackupStatus.alternativePercentage
$BackupStatus.filename


# Wait for backup to finish
do {
    $status = Invoke-RestMethod -Method Get -Headers $header -Uri "https://$account.atlassian.net/wiki/rest/obm/1.0/getprogress"
        $BackupStatus = convertfrom-json $GetBackupID.content
        $BackupStatus.alternativePercentage
    $statusoutput = $BackupStatus.alternativePercentage
    $separator = ","
    $option = [System.StringSplitOptions]::None
    $s

    if ($statusoutput -eq "100%") {
        $percentage = "100"

        Write-Progress -Activity 'Creating backup' -Status $statusoutput -PercentComplete $percentage
    }
    Start-Sleep -Seconds 5
} while($statusoutput -ne '100%')

# Download
if ([bool]($status.PSObject.Properties.Name -match "failedMessage")) {
    throw $status.failedMessage
}
   
                     
$FileName = $BackupStatus.filename
$DownloadURI = "https://$account.atlassian.net/wiki/download/$FileName"

Invoke-WebRequest -Method Get -Headers $header -WebSession $session -Uri $DownloadURI -OutFile (Join-Path -Path $destination -ChildPath "confluence-backup-$today.zip") 
