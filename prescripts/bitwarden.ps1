#Unlock bitwarden vault!

#If custom server url, set 
if($ENV:BW_SERVER){
    bw config server $ENV:BW_SERVER
}
#Print bitwarden server in use
"Bitwarden is using server: $(bw config server)"
#Login using API key from env's
bw login --apikey
#Unlock the vault after login
$env:BW_SESSION=bw unlock --passwordenv BW_PASSWORD --raw
"Session: $env:BW_SESSION"
