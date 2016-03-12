#!/bin/bash
#scrip to get OCS count success and fail rate
echo -e "\n\033[05mMail-ID\033[0m
Please Enter the \033[04mMail-id\033[0m you want the report to mail on"
read mail_to
echo -e "\n\n\033[05mDate\033[0m
Please enter the Date in format \033[04mdd/mm/yy\033[0m"
read dte
IFS="/"
set -- ${dte}
dd=${1};mm=${2};yy=${3}
unset IFS
clear
echo  -e "\n\n\033[05mHour\033[0m
* For multiple consecutive hours, Please enter the range in format \033[04mhr1..hr2\033[0m
* For single hour, Please enter only one hour in format \033[04mhr1\033[0m"
read hour 

echo ${hour} | grep -e "\.\." > /dev/null
if [ `echo $?` == 0 ]; then
IFS=".."
set -- ${hour}
hr1=$1
hr2=$3
unset IFS
else 
hr1=${hour}
hr2=${hour}
fi
clear
echo -e "\n\n\033[05mPlease select from below region\033[0m 
\033[04musva usor euir apac\033[0m
* For all region input \033[04mall\033[0m
\033[01m* For multiple regions input in format \033[04mreg1,reg2,reg3\033[0m\033[0m
* For single region just input the single region. \033[04mreg1\033[0m"
read region
clear 
#to check region
#for i in ${reg[@]}; do echo $i ; done 
ocs_count()
{
zcat *.gz | awk -F'\t' '{print $82}' > my_ocs_count;
zeros=`grep -c 0 my_ocs_count`
ones=`grep -c 1 my_ocs_count`
twos=`grep -c 2 my_ocs_count`
threes=`grep -c 3 my_ocs_count`
fours=`grep -c 4 my_ocs_count`
fives=`grep -c 5 my_ocs_count`
total=`wc -l my_ocs_count | awk '{print $1}'`
success=`echo "$ones + $fives" | bc`
#echo -e "OCS response code \t\t    Percent"
#echo -e "0\t\t\t\t\t$((zeros *100 /total))"
#echo -e "1\t\t\t\t\t$((ones *100 /total))"
#echo -e "2\t\t\t\t\t$((twos *100 /total))"
#echo -e "3\t\t\t\t\t$((threes *100 /total))"
#echo -e "4\t\t\t\t\t$((fours *100 /total))"
#echo -e "5\t\t\t\t\t$((fives *100 /total))"
echo -e "$1\t$2\t$((success *100 /total))\t\t$((twos *100 /total))" >> /tmp/arpit/ocs_success_fail_per.ocs
}



if [ ${region} == "all" ]; then 
reg=(usva usor euir apac)
else
reg=${region}
fi

for  region in ${reg[@]}; do
mkdir ${region} 
cd ${region}
for hour in `seq -w ${hr1} ${hr2}` ; do
mkdir ${hour} 
cd ${hour} 
case ${region}  in 
usva)
s3cmd ls -r s3://ttv-logs/tsv/adserver/y=${yy}/m=${mm}/d=${dd}/h=${hour}/ | awk '{print $NF}' > file_list
head -5 file_list | while read line ; do s3cmd get --skip-existing "$line" ; done
ocs_count ${hour} ${region}
cd ..;;
euir)
s3cmd ls -r s3://vg-eu-west-1-logs/tsv/adserver/y=${yy}/m=${mm}/d=${dd}/h=${hour}/ | awk '{print $NF}' > file_list
head -5 file_list | while read line ; do s3cmd get --skip-existing "$line"; done
ocs_count ${hour} ${region}
cd ..;;
apac)
s3cmd ls -r s3://vg-singapore-logs/tsv/adserver/y=${yy}/m=${mm}/d=${dd}/h=${hour}/ | awk '{print $NF}' > file_list
head -5 file_list | while read line ; do s3cmd get --skip-existing "$line" ; done
ocs_count ${hour} ${region}
cd ..;;
usor)
s3cmd ls -r s3://vg-oregon-logs/tsv/adserver/y=${yy}/m=${mm}/d=${dd}/h=${hour}/ | awk '{print $NF}' > file_list
head -5 file_list | while read line ; do s3cmd get --skip-existing "$line" ; done
ocs_count ${hour} ${region}
cd ..;;
*)
echo "Wrong region selected"
echo "exiting Now..."
exit ;;
esac
done
cd ..
done

find -type f -name *.ocs -exec cat {} \; | grep usva | sort -k1 >> total_ocs_count
find -type f -name *.ocs -exec cat {} \; | grep usor | sort -k1 >> total_ocs_count
find -type f -name *.ocs -exec cat {} \; | grep euir | sort -k1 >> total_ocs_count
find -type f -name *.ocs -exec cat {} \; | grep apac | sort -k1 >> total_ocs_count
sed -i '1i Hour\tRegion\tsuccess\t\tfail' total_ocs_count
mutt -s "OCS count" -- ${mail_to} < total_ocs_count
if [ $? == 0 ]; then echo "report is mailed to id: ${mail_to}" ; fi
cat /dev/null > total_ocs_count
cat /dev/null > file_list
for  region in ${reg[@]}; do
rm -rf ${region}
done




