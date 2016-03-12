#!/bin/bash
PATH=/bin:/usr/bin:/usr/local/share/ec2_tools/bin
export EC2_HOME="/usr/local/share/ec2_tools"
export JAVA_HOME="/usr/lib/jvm/java"

action="$1"
if [ "$action" == "" ]
then
  echo "$0 [start|stop|status]"
  exit 1
fi
source /home/vlg/etc/aws/videology.cfg
export AWS_ACCESS_KEY="$aws_access_key_id"
export AWS_SECRET_KEY="$aws_secret_access_key"
instances="i-5b72cfa4 i-b265d84d i-0e68d5f1 i-b98b3646 i-e565d81a"
for i in $instances
do
  if [ "$action" == "start" ]
  then
    ec2-start-instances $i
  fi
  if [ "$action" == "stop" ]
  then
    ec2-stop-instances $i
  fi
  if [ "$action" == "status" ]
  then
    ec2-describe-instances $i
    echo
  fi
done
