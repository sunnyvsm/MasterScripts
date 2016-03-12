#!/bin/bash
# script to snapshot an ec2 volume

PATH=/bin:/usr/bin:/usr/local/share/ec2_tools/bin

export EC2_HOME=/usr/local/share/ec2_tools
export JAVA_HOME=/usr/lib/jvm/java
export PATH=$EC2_HOME/bin:$JAVA_HOME/bin:$PATH
export AWS_ACCESS_KEY="$aws_access_key_id"
export AWS_SECRET_KEY="$aws_secret_access_key"


aws_cfg=/home/vlg/etc/aws/videology.cfg
vol_id=$1
reten_policy=$2
desc="snapshot_`date +%Y-%m-%d`"
out_file=/tmp/snap_details
retention_file=/tmp/snap_data

fromdate=$(date "+%Y-%m-%d" -d "${reten_policy} day ago")

if [ ! -f "$aws_cfg" ]
then
  echo "$aws_cfg does not exist"
  exit 1
fi
source $aws_cfg


# create the snapshot

#ec2-create-snapshot ${vol_id} -O $aws_access_key_id -W $aws_secret_access_key --description ${desc}

# delete the 15 day old snapshot created from the volume

ec2-describe-snapshots -F volume-id="${vol_id}" -O $aws_access_key_id -W $aws_secret_access_key | grep $fromdate > ${retention_file}
if [ -s ${retention_file} ] ;then 

cat ${retention_file} | awk '{print $2}' | xargs -n 1 -t ec2-delete-snapshot -O $aws_access_key_id -W $aws_secret_access_key 
fi
