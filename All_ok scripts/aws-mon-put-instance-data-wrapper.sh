#!/bin/bash
PATH=/bin:/usr/bin

aws_cfg=/home/vlg/etc/aws/videology.cfg
if [ ! -f "$aws_cfg" ]
then
  echo "$aws_cfg does not exist"
  exit 1
fi
source $aws_cfg

exec=/home/vlg/bin/aws-scripts-mon/mon-put-instance-data.pl
if [ ! -f "$exec" ]
then
  echo "$exec does not exist"
  exit 1
fi

mounts=$(df -Pl | grep -vi mounted | awk '{print $NF}')
for i in $mounts
do
  if [ "$disk_path" != "" ]
  then
    disk_path="$disk_path --disk-path=$i"
  else
    disk_path="--disk-path=$i"
  fi
done

$exec --mem-util --mem-used --mem-avail --disk-space-util $disk_path --aws-access-key-id=$aws_access_key_id --aws-secret-key=$aws_secret_access_key --from-cron
