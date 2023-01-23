#dismount 
umount $ENV:SOURCEDIR
umount $ENV:OVERLAY_PATH/overlay
umount $ENV:OVERLAY_PATH/low

remove-item -recurse -force $ENV:OVERLAY_PATH/overlay
remove-item -recurse -force $ENV:OVERLAY_PATH/low