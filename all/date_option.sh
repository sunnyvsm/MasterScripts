#!/bin/bash
#Program to check the events
#echo "Please enter the days you want the log of"
#read date

function ip()
{
echo "Please input the date"
read dte
}
function arp_date()
{
clear
for (( i=1; i<= $2; i++ ))
do
#date "+%Y-%m-%d" -d "-$i days"i
if [ $1 -eq 1 ]
then
cat /tmp/ins_date | grep -B4 EVENT  | grep -v "SYSTEMSTATUS\|INSTANCESTATUS" |grep -B1 `date "+%Y-%m-%d" -d "-$i days"` |awk  '{if ($1 == "INSTANCE") print$1,$2 ; else if ($1== "EVENT") print $2,$3,$4 }'
else
cat /tmp/ins_date | grep -B4 EVENT  | grep -v "SYSTEMSTATUS\|INSTANCESTATUS" |grep -B1 `date "+%Y-%m-%d" -d "$i days"` |awk  '{if ($1 == "INSTANCE") print$1,$2 ; else if ($1== "EVENT") print $2,$3,$4 }'
fi
echo " "
done

}
echo "
Main MENU
1> To display log of Past dates
2>To display log of Future dates
3> exit"

read opt
case $opt in
1)echo "Past Dated log calculation"
echo "Please enter the date you want the log of"
read dte
arp_date 1 $dte;;
2)echo "Future Dates log calculation"
echo "Please enter the date you want the log of"
read dte
arp_date 0 $dte;;
3)echo "Wrong Choice" ;;
*)echo "Wrong Choice" ;;
esac
