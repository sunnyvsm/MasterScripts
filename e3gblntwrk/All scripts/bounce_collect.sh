#!/bin/bash
#Program to get bounce data
#last updated on 01/12/2015: removed error code 521 from isp aol + added condition if log file is empty

bounce_path="/var/log/pmta/bounce_data"
if [ ! -d $bounce_path ] ; then
mkdir -p ${bounce_path}
fi
dte=$(date --date="1 day ago" +"%Y-%m-%d")
log_file="/var/log/pmta/acct-$dte-*.csv"
file_count=`ls $log_file | wc -l`
code=b
#isp=(aol.com gmail.com hotmail.co.uk googlemail.com hotmail.com live.com live.co.uk msn.com outlook.com rocketmail.com yahoo.com yahoo.co.uk ymail.com)
isp=`cat $log_file | awk -F "," '{print $5}' | awk -F "@" '{print $2}' | sort -u`
if [ -z $isp ]; then
echo "NO ISP LOG FOUND IN LOG FILES" $log_file
echo "Program Exiting Now..."
sleep .50
exit
else
for  i in ${isp[@]}; do
case $i in
"aol.com")
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "aol" | grep "550" | awk -F "," '{print $5}' | sort -u > $bounce_path/aol.com_bounce_$dte
bnc_cnt=`wc -l $bounce_path/aol.com_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;
"gmail.com")
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "gmail.com" | grep "550" | awk -F "," '{print $5}' | sort -u > $bounce_path/gmail.com_bounce_$dte
bnc_cnt=`wc -l $bounce_path/gmail.com_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;
"googlemail.com")
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "googlemail.com" | grep "550" | awk -F "," '{print $5}' | sort -u > $bounce_path/googlemail.com_bounce_$dte
bnc_cnt=`wc -l $bounce_path/googlemail.com_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;
"hotmail.com")
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "hotmail.com" | grep "550" | awk -F "," '{print $5}' | sort -u > $bounce_path/hotmail.com_bounce_$dte
bnc_cnt=`wc -l $bounce_path/hotmail.com_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;

"hotmail.co.uk")
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "hotmail.com" | grep "550" | awk -F "," '{print $5}' | sort -u > $bounce_path/hotmail.co.uk_bounce_$dte
bnc_cnt=`wc -l $bounce_path/hotmail.co.uk_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;

"live.com")
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "live.com" | grep "550" | awk -F "," '{print $5}' | sort -u > $bounce_path/live.com_bounce_$dte
bnc_cnt=`wc -l $bounce_path/live.com_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;

"live.co.uk")
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "live.co.uk" | grep "550"  | awk -F "," '{print $5}' | sort -u > $bounce_path/live.co.uk_bounce_$dte
bnc_cnt=`wc -l $bounce_path/live.co.uk_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;

"msn.com")
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "msn.com" | grep "550" | awk -F "," '{print $5}' | sort -u > $bounce_path/msn.com_bounce_$dte
bnc_cnt=`wc -l $bounce_path/msn.com_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;

"outlook.com")
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "outlook.com" | grep "550" | awk -F "," '{print $5}' | sort -u  > $bounce_path/outlook.com_bounce_$dte
bnc_cnt=`wc -l $bounce_path/outlook.com_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;

"rocketmail.com")
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "rocketmail.com" | grep "550" | awk -F "," '{print $5}' | sort -u  > $bounce_path/rocketmail.com_bounce_$dte
bnc_cnt=`wc -l $bounce_path/rocketmail.com_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;

"yahoo.com")
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "yahoo.com" | grep "554"  | awk -F "," '{print $5}' | sort -u > $bounce_path/yahoo.com_bounce_$dte
bnc_cnt=`wc -l $bounce_path/yahoo.com_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;

"ymail.com")
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "ymail.com" | grep "554"  | awk -F "," '{print $5}' | sort -u > $bounce_path/ymail.com_bounce_$dte
bnc_cnt=`wc -l $bounce_path/ymail.com_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;

"yahoo.co.uk")
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "yahoo.co.uk" | grep "554"  | awk -F "," '{print $5}' | sort -u > $bounce_path/yahoo.co.uk_bounce_$dte
bnc_cnt=`wc -l $bounce_path/yahoo.co.uk_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;

*)
cat $log_file | awk -F "," '$1 == "'"$code"'" {print $0}' | grep "554\|550" | awk -F "," '{print $5}' | sort -u > $bounce_path/other_bounce_$dte
bnc_cnt=`wc -l $bounce_path/other_bounce_$dte | awk 'OFS="\t"{ print $2" is =>",$1}'`
echo "Total bounce data stored in file $bnc_cnt";;

esac
done
fi
