#!/bin/bash
#Program to check the events
#echo "Please enter the days you want the log of"
#read date
for (( i=1 ; i<="$1"; i++))
do
#date "+%Y-%m-%d" -d "-$i days"
cat /tmp/ins_date | grep -B4 EVENT  | grep -v "SYSTEMSTATUS\|INSTANCESTATUS" |grep -B1 `date "+%Y-%m-%d" -d "$i days"` |awk  '{if ($1 == "INSTANCE") print$1,$2 ; else if ($1== "EVENT") print $2,$3,$4 }'
done
cat /dev/null > /tmp/date