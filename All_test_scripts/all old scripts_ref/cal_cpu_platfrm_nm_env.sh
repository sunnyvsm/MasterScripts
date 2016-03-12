#!/bin/bash
# script to calculate the instance finformation along with platform ,name,env and peak cpu used
# output format :
#i-08afd3e5|us-east-1c|usvavdseprd|Maya|Production|c1.medium|running|48.81%
#sh <filename> <number of days>
#necessary file required for program 
#1>input file where all instances information is downloaded "all_inst_info"
cpu()
{
range=$1
instance=$2
OrgRgn=$3

fromdate=$(date "+%Y-%m-%d" -d "${range} day ago")
todate=$(date "+%Y-%m-%d" -d "1 day ago")

#instanceList=$(cat ${file} | awk '{print $1}')

for inst in ${instance}; do
                rgn=$(echo "${OrgRgn%?}")
        ind_mat=$(aws cloudwatch get-metric-statistics --metric-name CPUUtilization --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace AWS/EC2 --statistics Maximum --dimensions Name=InstanceId,Value=${inst} --region ${rgn} | grep -v CPUUtilization | awk {'print $2'})
        avg_cpu=0
        for i in ${ind_mat}; do
                avg_cpu=(${avg_cpu}+${i})
        done
        avg_cpu=$(echo "${avg_cpu}" | bc)
        avg_cpu=$(echo "${avg_cpu}/${range}" | bc -l)
                fl=$(printf "%0.2f\n" ${avg_cpu})
        echo -e "${fl}"%
done
}


inst_all=`cat all_inst_info | grep -w -e "INSTANCE" | awk '{print $2}'`
for i in $inst_all
do
inst=$i
rgn=`cat all_inst_info | grep "$i" | sed 's/\t/|/g' | awk -F "|" '{print $12}' | sed '/^$/d'`
name=`cat all_inst_info | grep "$i" | grep TAG | grep -w "Name" | awk '{print $NF}'| sed '/^$/d'`
pltfrm=`cat all_inst_info | grep "$i" | grep TAG | grep -w "Platform" | awk '{print $NF}'| sed '/^$/d'`
env=`cat all_inst_info | grep "$i" | grep TAG | grep -w "Environment"| awk '{print $NF}'| sed '/^$/d'`
type=`cat all_inst_info | grep "$i" | sed 's/\t/|/g' | awk -F "|" '{print $10}'| sed '/^$/d'`
cpu=`cpu ${1} ${inst} ${rgn}`

status=`cat all_inst_info | grep "$i" | sed 's/\t/|/g' | awk -F "|" '{print $6}'| sed '/^$/d'`

echo -e "$inst|$rgn|$name|$pltfrm|$env|$type|$status|$cpu" >> all_infooutput
done
