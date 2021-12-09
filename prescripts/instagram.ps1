cd $ENV:SOURCEDIR

#create directory
if(test-path $ENV:SOURCEDIR){}
else {mkdir $ENV:SOURCEDIR}

#run instaloader to download public profile, does not re-download because of --fast-update
$ENV:INSTAGRAM_PROFILES.split(" ") | foreach-object {
    instaloader $_ --fast-update --quiet --login $ENV:INSTAGRAM_LOGIN --password $ENV:INSTAGRAM_PASSWORD
}