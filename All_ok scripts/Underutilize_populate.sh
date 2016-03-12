#!/bin/bash
#script to get underutilize instances details.
#underutilize_report generator v1.11 [04/27/2015]
#input validation
#bug fixes
#script name <vid_file> <mail_id>
underutilize_data()
{
echo -ne "."
export AWS_ACCESS_KEY_ID=$3
export AWS_SECRET_ACCESS_KEY=$4

acc=$1
path=$2
#app_tag=`cat ${path}| grep "TAG" |grep -w "Application" | awk '{$1=$2=$3=$4="" ; print $0}' |sed -e 's/^[[:space:]]*//'`
#env_tag=`cat ${path}| grep "TAG" |grep -w "Environment" | awk '{$1=$2=$3=$4="" ; print $0}' |sed -e 's/^[[:space:]]*//'`
#plt_tag=`cat ${path}| grep "TAG" | grep -w "Platform" | awk '{$1=$2=$3=$4="" ; print $0}' | sed -e 's/^[[:space:]]*//'`
#name_tag=`cat ${path}| grep "TAG" | grep -w "Name" | awk '{$1=$2=$3=$4="" ; print $0}' | sed -e 's/^[[:space:]]*//'`
os=`cat  ${path}| grep "INSTANCE" | awk -F "\t" '{print $15}' | sed -e 's/^[[:space:]]*//'`
inst_type=`cat ${path}| grep "INSTANCE" | awk -F "\t" '{print $10}' | sed -e 's/^[[:space:]]*//'`
inst=`cat ${path}| grep "INSTANCE" | awk -F "\t" '{print $2}' | sed -e 's/^[[:space:]]*//'`
reg=`cat ${path}| grep "INSTANCE" | awk -F "\t" '{print $12}' | sed -E 's/(.*)[a-z]$/\1/' | sed -e 's/^[[:space:]]*//'`
fromdate=$(date "+%Y-%m-%d" -d "7 day ago")
todate=$(date "+%Y-%m-%d" -d "1 day ago")
if [ -z "$os" ] ; then os=linux; namespace=System/Linux ; else os=mswin ; namespace=System/Windows; fi
total_memory=`cat /tmp/ec2instances_info | grep -A5 ${inst_type} | grep -w memory | sed -E  's/(<.*>)(<.*>)(.*)(<\/.*>)(<\/.*>)$/\3/' | tr -s " " | sed -E 's/([0-9].*)\s.*$/\1/' | sed -e 's/^[[:space:]]*//'`
#total_cost=`cat /tmp/ec2instances_info | grep -A50 ${inst_type} | grep -w cost-${os} | sed -E 's/^.*\{(.*)\}.*$/\1/' | sed 's/&#34;//g'|  sed 's/,/\n/g'| grep ${reg} |  awk -F: '{print $2*720}'`

#default metrics
#peak_cpu=`aws cloudwatch get-metric-statistics --metric-name CPUUtilization --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace  AWS/EC2 --statistics Maximum --dimensions Name=InstanceId,Value=${inst}  --region ${reg} | grep -v CPUUtilization |awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}' 2> /dev/null`
#avg_cpu=`aws cloudwatch get-metric-statistics --metric-name CPUUtilization --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace  AWS/EC2 --statistics Average --dimensions Name=InstanceId,Value=${inst}  --region ${reg} | grep -v CPUUtilization |awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}' 2> /dev/null`

#below two metrics give value in percetage
max_mem_per=`aws cloudwatch get-metric-statistics --metric-name MemoryUtilization --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace ${namespace} --statistics Maximum --dimensions Name=InstanceId,Value=${inst}  --region ${reg} | grep -v MemoryUtilization |awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}' 2> /dev/null`
avg_mem_per=`aws cloudwatch get-metric-statistics --metric-name MemoryUtilization --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace ${namespace} --statistics Average --dimensions Name=InstanceId,Value=${inst}  --region ${reg} | grep -v MemoryUtilization |awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}' 2> /dev/null`

#below two metrics give value in MB

avg_avail_mem=`aws cloudwatch get-metric-statistics --metric-name MemoryAvailable --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace ${namespace} --statistics Average --dimensions Name=InstanceId,Value=${inst}  --region ${reg} | grep -v MemoryAvailable |awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}' 2> /dev/null`
avg_avail_mem=`aws cloudwatch get-metric-statistics --metric-name MemoryAvailable --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace ${namespace} --statistics Average --dimensions Name=InstanceId,Value=${inst}  --region ${reg} | grep -v MemoryAvailable |awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}' 2> /dev/null`
avg_used_mem=`aws cloudwatch get-metric-statistics --metric-name MemoryUsed --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace ${namespace} --statistics Average --dimensions Name=InstanceId,Value=${inst}  --region ${reg} | grep -v MemoryUsed |awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}' 2> /dev/null`

#echo -e "${reg}|${inst}|${inst_type}|${name_tag}|${app_tag}|${env_tag}|${plt_tag}|${total_cost}|${peak_cpu}|${avg_cpu}|${total_memory}|${max_mem_per}|${avg_mem_per}|${avg_avail_mem}|${avg_used_mem}" >> /tmp/Report_${acc}.xls
echo -e "${reg}|${inst}|${inst_type}|${total_memory}|${max_mem_per}|${avg_mem_per}|${avg_avail_mem}|${avg_used_mem}" >> /tmp/Report_${acc}.xls



}
file_check()
{
loop=1
file=$1
while [ ${loop} == 1 ] ; do
if [ -e ${file} ]; then
loop=0
echo "file present"
else
echo "File not present, Please input correct file"
read file
fi
done
}
##########MAIN###############
#variable Decalrations


echo "Do you want the Report for both account, Select all or vid/lmn"
read opt_acc
if [ ${opt_acc} == "all" ]; then
acc=(vid lmn)
echo "Please Input the videology File"
read vid_file
file_check ${vid_file}

echo "Please Input the LMN File"
read lmn_file
file_check ${lmn_file}

elif [ ${opt_acc} == "vid" ] ; then
acc=(vid)
echo "Please Input the videology File"
read vid_file
file_check ${vid_file}

elif [ ${opt_acc} == "lmn" ]; then 
acc=(lmn)
echo "Please Input the LMN File"
read lmn_file
file_check ${lmn_file}
else
echo "Incorrect option Selected
Program exiting Now"
exit

fi

echo "Please Input the Mail address"
read mail_to
res=`echo ${mail_to} | grep "@"`
if  [ ! -z ${mail_to} ] && [ ${?} == 0 ]  ; then
echo "Email id in proper format"
else 
echo "email_id incorrect or not supplied"
fi
from="no.reply@videologygroup.com"
subject="UNderutilize Report"
body="PFA"
################################
#downloading the EC2-instances costing info  data
wget -O /tmp/ec2instances_info  http://www.ec2instances.info &> /dev/null

#################################
#main part of program
for acc_t in ${acc[@]}; do
if [ ${acc_t} == "vid" ]; then
AK="AKIAIFVGUARTUV6HPHTQ"
SAK="2nYqGL7ehSMkugZX3gl/TtMofQ+PzKKHhTE/uynE"
file=${vid_file}
else
AK="AKIAJGCNJXKN7NPIQSOQ"
SAK="n/QbNZpu8kwnP98u8PjYHX8rCEjsDl/BYcPk6Fa5"
file=${lmn_file}
fi
cat ${file} | while read line ; do
ins=`echo $line | awk '{print $2}'`
region=`echo $line | awk '{print $1}'`
#acc=vid
ec2-describe-instances  ${ins} -F instance-state-name=running -O ${AK} -W ${SAK} --region ${region} > /tmp/data_${acc_t}
if [ -s /tmp/data_${acc_t} ] ; then
underutilize_data ${acc_t} /tmp/data_${acc_t} ${AK} ${SAK}
fi

done
if [ -s /tmp/Report_${acc_t}.xls ] ; then
sed -i '1i REGION|INSTANCE-ID|INSTANCE-TYPE|TOTAL-MEM(GB)|PEAK-MEM-USED(%)|AVG-MEM-USED(%)|AVG-MEM-AVAIL(MB)|AVG-MEM-USED(MB)' /tmp/Report_${acc_t}.xls

sed -i 's/|/\t/g' /tmp/Report_${acc_t}.xls
echo ${body}| mutt -e "set from=${from}" -s "${subject}" -a /tmp/Report_${acc_t}.xls  -- "${mail_to}"

if [ $? != 0 ]; then echo "Error, While Sending the Mail, Please find the Report  at /tmp/Report_${acc_t}.xls"
else
echo -e "\nReport for account ${acc_t} has been sent to ${mail_to}, please check!!"
cat /dev/null > /tmp/Report_${acc_t}.xls
cat /dev/null > /tmp/data_${acc_t}
fi
else 
echo "File /tmp/data_${acc_t} Empty , Report not generated"
fi 
done
