#!/bin/bash
# script to calculate the instance finformation along with platform ,name,env and peak cpu used
# output format :
#i-08afd3e5|us-east-1c|usvavdseprd|Maya|Production|c1.medium|running|48.81%
#sh <filename> <number of days>
#necessary file required for program
#1>input file where all instances information is downloaded "/tmp/alldata_${account}"
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

disk_read()
{
range=$1
instance=$2
OrgRgn=$3

fromdate=$(date "+%Y-%m-%d" -d "${range} day ago")
todate=$(date "+%Y-%m-%d" -d "1 day ago")

#instanceList=$(cat ${file} | awk '{print $1}')

for inst in ${instance}; do
        rgn=$(echo "${OrgRgn%?}")
        ind_rd=$(aws cloudwatch get-metric-statistics --metric-name DiskReadBytes --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace AWS/EC2 --statistics Maximum --dimensions Name=InstanceId,Value=${inst} --region ${rgn} | grep -v DiskReadBytes | awk {'print $2'})
        avg_dskrd=0
        for i in ${ind_rd}; do
                avg_dskrd=(${avg_dskrd}+${i})
        done
        avg_dskrd=$(echo "${avg_dskrd}" | bc)
        avg_dskrd=$(echo "${aavg_dskrd}/${range}" | bc -l)
        f2=$(printf "%0.2f\n" ${avg_dskrd})
        echo -e "${f2}"
done
}



disk_write()
{
range=$1
instance=$2
OrgRgn=$3

fromdate=$(date "+%Y-%m-%d" -d "${range} day ago")
todate=$(date "+%Y-%m-%d" -d "1 day ago")

#instanceList=$(cat ${file} | awk '{print $1}')

for inst in ${instance}; do
        rgn=$(echo "${OrgRgn%?}")
        ind_wrt=$(aws cloudwatch get-metric-statistics --metric-name DiskWriteBytes --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace AWS/EC2 --statistics Maximum --dimensions Name=InstanceId,Value=${inst} --region ${rgn} | grep -v DiskWriteBytes | awk {'print $2'})
        avg_wrt=0
        for i in ${ind_wrt}; do
                avg_wrt=(${avg_wrt}+${i})
        done
        avg_wrt=$(echo "${avg_wrt}" | bc)
        avg_wrt=$(echo "${avg_wrt}/${range}" | bc -l)
                f3=$(printf "%0.2f\n" ${avg_wrt})
        echo -e "${f3}"
done
}

aws_region_array=(eu-west-1 sa-east-1 us-east-1 ap-northeast-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2)
aws_account_array=("VIDEOLOGY LMN VIDEOLOGYDEV")
for account in ${aws_account_array[@]}; do

         if [ "$account" == "VIDEOLOGY" ]; then
                  AK="AKIAIFVGUARTUV6HPHTQ"
                  SAK="2nYqGL7ehSMkugZX3gl/TtMofQ+PzKKHhTE/uynE"
                                export AWS_ACCESS_KEY='AKIAIFVGUARTUV6HPHTQ'
                                export AWS_SECRET_KEY='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'

elif [ "$account" == "LMN" ]; then
                  AK="AKIAJGCNJXKN7NPIQSOQ"
                  SAK="n/QbNZpu8kwnP98u8PjYHX8rCEjsDl/BYcPk6Fa5"
                              export AWS_ACCESS_KEY='AKIAJGCNJXKN7NPIQSOQ'
                                  export AWS_SECRET_KEY='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'

elif [ "$account" == "VIDEOLOGYDEV" ]; then
                  AK="AKIAIEGEZTXTZ5HIMCPA"
                  SAK="q38ua+3Z5zwERt/AYSsBacFxwuLJhGB2ptr/i6eh"
                                export AWS_ACCESS_KEY='AKIAIEGEZTXTZ5HIMCPA'
                                export AWS_SECRET_KEY='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'

         fi

echo "Downloading the instance information for Account ${account}"
         for rgn in ${aws_region_array[@]}; do

         ec2-describe-instances  --region ${rgn} -O ${AK} -W ${SAK} >> /tmp/alldata_${account}
done


inst_all=`cat /tmp/alldata_${account} | grep -w -e "INSTANCE" | awk '{print $2}'`
for i in $inst_all
do
inst=$i
rgn=`cat /tmp/alldata_${account} | grep "$i" | sed 's/\t/|/g' | awk -F "|" '{print $12}' | sed '/^$/d'`
name=`cat /tmp/alldata_${account} | grep "$i" | grep TAG | grep -w "Name" | awk '{print $NF}'| sed '/^$/d'`
pltfrm=`cat /tmp/alldata_${account} | grep "$i" | grep TAG | grep -w "Platform" | awk '{print $NF}'| sed '/^$/d'`
env=`cat /tmp/alldata_${account} | grep "$i" | grep TAG | grep -w "Environment"| awk '{print $NF}'| sed '/^$/d'`
type=`cat /tmp/alldata_${account} | grep "$i" | sed 's/\t/|/g' | awk -F "|" '{print $10}'| sed '/^$/d'`
cpu=`cpu ${1} ${inst} ${rgn}`
disk_read=`disk_read ${1} ${inst} ${rgn}`
disk_write=`disk_write ${1} ${inst} ${rgn}`
app=`cat /tmp/alldata_${account} | grep "$i" | grep TAG | sed 's/\t/|/g' |grep -w "Application"  | awk -F "|" '{print $5}'`
status=`cat /tmp/alldata_${account} | grep "$i" | sed 's/\t/|/g' | awk -F "|" '{print $6}'`

echo -e "$inst|$rgn|$name|$pltfrm|$env|$type|$status|$app|$cpu|$disk_read|$disk_write" >> /tmp/output_${account}
done
done
