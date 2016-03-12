#!/bin/bash/
#s3fileupload.sh <app_log_location> <s3location> <mailtaddr>
app_lg_lct=$1 ; def_app_lg_lct=/tmp/ftp_home/
s3_locn=$2 ;def_s3_locn=s3://s3uploadarpit/test1/
mail=$3 ; def_mail="akohale@videologygroup.com"

app_lg_lct=${app_lg_lct:-$def_app_lg_lct}
s3_locn=${s3_locn:-$def_s3_locn}
mail=${mail:-$def_mail}

if [ ! -d "$app_lg_lct" ] ; then

echo "Supplied App log file location \"$app_lg_lct\"  over \"$HOSTNAME\" does not exist" |  mail -s "ERROR-While uploading files over s3" $mail 2> /dev/null

exit
else
if [ -e ~/.s3cfg ] ; then
cd $app_lg_lct
s3cmd sync --recursive $app_lg_lct $s3_locn  2> /tmp/s3_upload_error_` date +%d%m%y_%H%m`
else
echo "S3cmd not installed/configured over instance $HOSTNAME for user $USER" |  mail -s "ERROR-While uploading files over s3" $mail 2> /dev/null
exit
fi
fi

