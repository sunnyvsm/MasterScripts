#!/bin/bash
#Script to pull the information like Platform,Environment,Name,Application,CPU-peak/avg,disk-read/write
#creation-date:11/09/2014
if [ -e output ] ; then
cat /dev/null > output
fi

region=(eu-west-1 sa-east-1 us-east-1 ap-northeast-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2)
account=("VIDEOLOGY LMN VIDEOLOGYDEV")
echo "Downloading the data"
for acc in ${account[@]}; do
echo -ne "."
	if [ "$acc" == "VIDEOLOGY" ]; then
		AK="AKIAIFVGUARTUV6HPHTQ"
		SAK="2nYqGL7ehSMkugZX3gl/TtMofQ+PzKKHhTE/uynE"
		export AWS_ACCESS_KEY='AKIAIFVGUARTUV6HPHTQ'
		export AWS_SECRET_KEY='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'
	elif [ "$acc" == "LMN" ]; then 
		AK="AKIAJGCNJXKN7NPIQSOQ"
		SAK="n/QbNZpu8kwnP98u8PjYHX8rCEjsDl/BYcPk6Fa5"
		export AWS_ACCESS_KEY='AKIAJGCNJXKN7NPIQSOQ'
		export AWS_SECRET_KEY='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'
	elif [ "$acc" == "VIDEOLOGYDEV" ]  ; then
		AK="AKIAIEGEZTXTZ5HIMCPA"
		SAK="q38ua+3Z5zwERt/AYSsBacFxwuLJhGB2ptr/i6eh"
		export AWS_ACCESS_KEY='AKIAIEGEZTXTZ5HIMCPA'
		export AWS_SECRET_KEY='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'
	fi

for rgn in ${region[@]} ; do
	ec2-describe-instances -O $AK -W $SAK --region $rgn >> output
done
done

if [ `wc -l output | awk '{print $1}'` -le  1 ] ; then 
echo "File not Downloaded, please download it and try again"
fi

echo "PLease specify the CSV file(specify the exact path)"
read file
echo "PLease select the information you want to insert in file
1.Platform
2.Name
3.Application
4.Environment
5.Avg CPU,Peak CPU,Disk Read,Disk Write
6.ALL THE ABOVE
"
read opt

for i in  ${opt[@]} ; do
case $i in
1) echo "You had select the Platform Information"
cat ${file} | while read line ; do echo -ne "$line" ; cat output | grep `echo $line | awk '{print $1}'` | grep TAG | grep -w "Platform" | sed 's/\t/|/g' | awk -F "|" '{print "\t" $NF}'; echo -e ""  ; done | sed '/^$/d'
 ;;
2)echo "You had select the Name Information"
cat ${file} | while read line ; do echo -ne "$line" ; cat output | grep `echo $line | awk '{print $1}'` | grep TAG | grep -w "Name" | sed 's/\t/|/g' | awk -F "|" '{print "\t" $NF}'; echo -e ""  ; done | sed '/^$/d'
;;
3)echo "You had select the Applicaiton Information"
cat ${file} | while read line ; do echo -ne "$line" ; cat output | grep `echo $line | awk '{print $1}'` | grep TAG | grep -w "Application" | sed 's/\t/|/g' | awk -F "|" '{print "\t" $NF}'; echo -e ""  ; done | sed '/^$/d'
;;
4)echo "You had select the Environment Information"
cat ${file} | while read line ; do echo -ne "$line" ; cat output | grep `echo $line | awk '{print $1}'` | grep TAG | grep -w "Environment" | sed 's/\t/|/g' | awk -F "|" '{print "\t" $NF}'; echo -e ""  ; done | sed '/^$/d'
;;

5)echo "You had select the Peak CPU Information"
echo "please specify the days to calculate the CPU"
read range
echo "Please specify the Account (VIDEOLOGY,LMN,VIDEOLOGYDEV)"
read acc

if [ "$acc" == "VIDEOLOGY" ] ;then
export AWS_ACCESS_KEY_ID=AKIAIFVGUARTUV6HPHTQ
export AWS_SECRET_ACCESS_KEY=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
elif [ "$acc" == "LMN" ] ; then
export AWS_ACCESS_KEY_ID=AKIAJGCNJXKN7NPIQSOQ
export AWS_SECRET_ACCESS_KEY=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
elif [ "$acc" == "VIDEOLOGYDEV" ] ; then
export AWS_ACCESS_KEY_ID=AKIAIEGEZTXTZ5HIMCPA
export AWS_SECRET_ACCESS_KEY=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
fi

fromdate=$(date "+%Y-%m-%d" -d "${range} day ago")
todate=$(date "+%Y-%m-%d" -d "1 day ago")
cat ${file} | while read line; do
inst=`echo $line | awk '{print $1}'`
rgn=`cat output |  grep INSTANCE | grep ${inst} | sed 's/\t/|/g' | awk -F "|" '{print $12}' | sed -E 's/(.*)[a-z]$/\1/'`

cpa=`aws cloudwatch get-metric-statistics --metric-name CPUUtilization --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace AWS/EC2 --statistics Average --dimensions Name=InstanceId,Value=${inst} --region ${rgn} | grep -v CPUUtilization | awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}'`

cp=`aws cloudwatch get-metric-statistics --metric-name CPUUtilization --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace AWS/EC2 --statistics Maximum --dimensions Name=InstanceId,Value=${inst} --region ${rgn} | grep -v CPUUtilization | awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}'`

dr=`aws cloudwatch get-metric-statistics --metric-name DiskReadBytes --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace AWS/EC2 --statistics Average --dimensions Name=InstanceId,Value=${inst} --region ${rgn} | grep -v DiskReadBytes | awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}'`

dw=`aws cloudwatch get-metric-statistics --metric-name DiskWriteBytes --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace AWS/EC2 --statistics Average --dimensions Name=InstanceId,Value=${inst} --region ${rgn} | grep -v DiskWriteBytes | awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}'`
f0=$(printf "%0.2f\n" ${cpa})
fl=$(printf "%0.2f\n" ${cp})
f2=$(printf "%0.2f\n" ${dr})
f3=$(printf "%0.2f\n" ${dw})
#echo -e "${line}"$'\t'"${fl}"%$'\t'"${f2}"\t"$f3"
echo -e "${line}" $'\t' "${f0}"% $'\t' "${fl}"% $'\t' "${f2}" $'\t' "${f3}"  2> /dev/null
done
;;

6) echo "Populating All details"
cat ${file} | while read line ; do
plt=`cat output | grep `echo $line | awk '{print $1}'` | grep TAG | grep -w "Platform" | sed 's/\t/|/g' | awk -F "|" '{print "\t" $NF}'; echo -e ""  ; done | sed '/^$/d'`
app=`cat output | grep `echo $line | awk '{print $1}'` | grep TAG | grep -w "Application" | sed 's/\t/|/g' | awk -F "|" '{print "\t" $NF}'; echo -e ""  ; done | sed '/^$/d'`
env=`cat output | grep `echo $line | awk '{print $1}'` | grep TAG | grep -w "Environment" | sed 's/\t/|/g' | awk -F "|" '{print "\t" $NF}'; echo -e ""  ; done | sed '/^$/d'`
name=`cat output | grep `echo $line | awk '{print $1}'` | grep TAG | grep -w "Name" | sed 's/\t/|/g' | awk -F "|" '{print "\t" $NF}'; echo -e ""  ; done | sed '/^$/d'`

echo "please specify the days to calculate the CPU"
read range
echo "Please specify the Account (VIDEOLOGY,LMN,VIDEOLOGYDEV)"
read acc
if [ "$acc" == "VIDEOLOGY" ] ;then
export AWS_ACCESS_KEY_ID=AKIAIFVGUARTUV6HPHTQ
export AWS_SECRET_ACCESS_KEY=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
elif [ "$acc" == "LMN" ] ; then
export AWS_ACCESS_KEY_ID=AKIAJGCNJXKN7NPIQSOQ
export AWS_SECRET_ACCESS_KEY=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
elif [ "$acc" == "VIDEOLOGYDEV" ] ; then
export AWS_ACCESS_KEY_ID=AKIAIEGEZTXTZ5HIMCPA
export AWS_SECRET_ACCESS_KEY=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
fi

fromdate=$(date "+%Y-%m-%d" -d "${range} day ago")
todate=$(date "+%Y-%m-%d" -d "1 day ago")
inst=`echo $line | awk '{print $1}'`
rgn=`cat output |  grep INSTANCE | grep ${inst} | sed 's/\t/|/g' | awk -F "|" '{print $12}' | sed -E 's/(.*)[a-z]$/\1/'`

cpa=`aws cloudwatch get-metric-statistics --metric-name CPUUtilization --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace AWS/EC2 --statistics Average --dimensions Name=InstanceId,Value=${inst} --region ${rgn} | grep -v CPUUtilization | awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}'`

cp=`aws cloudwatch get-metric-statistics --metric-name CPUUtilization --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace AWS/EC2 --statistics Maximum --dimensions Name=InstanceId,Value=${inst} --region ${rgn} | grep -v CPUUtilization | awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}'`

dr=`aws cloudwatch get-metric-statistics --metric-name DiskReadBytes --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace AWS/EC2 --statistics Average --dimensions Name=InstanceId,Value=${inst} --region ${rgn} | grep -v DiskReadBytes | awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}'`

dw=`aws cloudwatch get-metric-statistics --metric-name DiskWriteBytes --start-time ${fromdate}T23:18:00 --end-time ${todate}T23:18:00 --period 86400 --namespace AWS/EC2 --statistics Average --dimensions Name=InstanceId,Value=${inst} --region ${rgn} | grep -v DiskWriteBytes | awk {'print $2'}  |awk '{ sum+=$1} END {print  (sum/NR)}'`
f0=$(printf "%0.2f\n" ${cpa})
fl=$(printf "%0.2f\n" ${cp})
f2=$(printf "%0.2f\n" ${dr})
f3=$(printf "%0.2f\n" ${dw})

echo -e "${line}" $'\t' "${plt}"% $'\t' "${app}"% $'\t' "${env}" $'\t' "${name}"$'\t' "${f0}"$'\t' "${f1}"$'\t' "${f2}"$'\t' "${f3}" 2> /dev/null
done;
;;

*)echo "You had select the Wrong Information" ;;

esac

done
