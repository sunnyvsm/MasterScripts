#!/bin/bash
php active_mq.php | grep -A 1 "opt.lp</a></td>\|opt.ns</a></td>\|opt.dg</a></td>" | sed -e 's/<td>\|<\/a>\|<\/td>\|--//g' | sed '/^$/d' |sed 'N;s/\n/ /' | while read line ; do
str=`echo $line | awk '{print $1}'`;
num=`echo $line | awk '{print $2}'`;
if [ $num -ge 0 ] ; then
echo "Warning Number of pending messages for ${str} are ${num}" | mailx -s "ACTIVE-MQ WARNING: Pending Message Exceeded for ${str}" akohale@videologygroup.com
fi
done