#!/bin/bash
#Program to rotate old pmta log files

#bounce_path="/var/log/pmta/bounce_data"
oldlog_filedir="/var/log/pmta/old_log_files"
if [ ! -d $oldlog_filedir ] ; then
mkdir -p /var/log/pmta/old_log_files/
fi
dte=$(date --date="1 day ago" +"%Y-%m-%d") 
log_file="/var/log/pmta/acct-$dte-*.csv"
for i in ${log_file[@]}; do
old_log_file=`echo $i | awk -F "/" '{print $NF}'`
if [ -e "$oldlog_filedir/$old_log_file" ]; then
echo "File already exists"
else
cp $i $oldlog_filedir
if [ $? == 0 ]; then
echo "Log file $i moved to location $oldlog_filedir"
fi
fi
done

