#!/bin/bash

range=$1
file=$2

fromdate=$(date "+%Y-%m-%d" -d "${range} day ago")
todate=$(date "+%Y-%m-%d" -d "1 day ago")

instanceList=$(cat ${file} | awk '{print $1}')

for inst in ${instanceList}; do
		OrgRgn=$(cat ${file} | grep ${inst} | awk '{print $2}')
		rgn=$(echo "${OrgRgn%?}")
        peak_mem=`aws cloudwatch get-metric-statistics --metric-name MemoryUtilization --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace System/Linux --statistics Maximum --dimensions Name=InstanceId,Value=${inst} --region ${rgn} | grep -v MemoryUtilization |awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}' 2> /dev/null`
		avg_mem=`aws cloudwatch get-metric-statistics --metric-name MemoryUtilization --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace System/Linux --statistics Average --dimensions Name=InstanceId,Value=${inst} --region ${rgn} | grep -v MemoryUtilization |awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}' 2> /dev/null`
        avg_cpu=0
        for i in ${ind_mat}; do
                avg_cpu=(${avg_cpu}+${i})
        done
        avg_cpu=$(echo "${avg_cpu}" | bc)
        avg_cpu=$(echo "${avg_cpu}/${range}" | bc -l)
		fl=$(printf "%0.2f\n" ${avg_cpu})
        echo -e "${inst}" $'\t' "${fl}"%
done

max_mem_per=`aws cloudwatch get-metric-statistics --metric-name MemoryUtilization --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace ${namespace} --statistics Maximum --dimensions Name=InstanceId,Value=${inst}  --region ${reg} | grep -v MemoryUtilization |awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}' 2> /dev/null`
avg_mem_per=`aws cloudwatch get-metric-statistics --metric-name MemoryUtilization --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace ${namespace} --statistics Average --dimensions Name=InstanceId,Value=${inst}  --region ${reg} | grep -v MemoryUtilization |awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}' 2> /dev/null`