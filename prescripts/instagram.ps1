cd $ENV:SOURCEDIR

#create directory
if(test-path $ENV:SOURCEDIR){}
else {mkdir $ENV:SOURCEDIR}

#run instaloader to download public profile, does not re-download because of --fast-update
$ENV:INSTAGRAM_PROFILES.split(" ") | foreach-object {
    instaloader profile $_ --fast-update --quiet --stories
}
