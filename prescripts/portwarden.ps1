"Starting Portwarden..."
echo $ENV:BW_PASSWORD | portwarden --passphrase $ENV:PORTWARDEN_PASSPHRASE --filename $ENV:SOURCEDIR/$ENV:PORTWARDEN_VAULTNAME encrypt
"Portwarden complete!"