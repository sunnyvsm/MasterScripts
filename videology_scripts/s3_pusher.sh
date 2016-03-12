#!/bin/bash/
#s3fileupload.sh <app_log_location> <s3location> <mailtaddr>
app_lg_lct=$1 ; def_app_lg_lct=/tmp/ftp_home
s3_locn=$2 ;def_s3_locn="s://ttv-testing/normalizer-root/app-logs/"
mail=$3 ; def_mail="akohale@videologygroup.com"

app_lg_lct=${app_lg_lct:-$def_app_lg_lct}
s3_locn=${s3_locn:-$def_s3_locn}
mail=${mail:-$def_mail}

if [ ! -d "$app_lg_lct" ] ; then
echo "Supplied App log location does not exist"
exit
else
if [ -e ~/.s3cfg ] ; then 
cd $app_lg_lct
aws s3 sync $app_lg_lct $s3_locn  2> /tmp/s3_upload_error
else
echo "S3cmd tool not installed"  > /tmp/s3_upload_error
exit
fi



aws s3 sync myfolder s3://mybucket/myfolder --exclude *.tmp.com 2> /dev/null



