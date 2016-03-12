#!/bin/bash

#export EC2_HOME=/home/ec2-user/common/ec2
#export JAVA_HOME=/home/ec2-user/java
#export PATH=$EC2_HOME/bin:$JAVA_HOME/bin:$PATH

EMAIL_FROM="no.reply@videologygroup.com"
EMAIL_ID="tmishra@videologygroup.com"
EMAIL_ID1=""
SUBJECT="Region wise information about Scheduled Instance Reboots and Retirement with Platform"

#Declare the temporary directory location
tmp_dir=/tmp

#Please add region names if I forgot to add to the array
aws_region_array=(eu-west-1 sa-east-1 us-east-1 ap-northeast-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2)

#Add account names to the array
aws_account_array=(VIDEOLOGY LMN VIDEOLOGYDEV)

date_range=$1

event () {
#echo -e Instance-ID $'\t' Region $'\t' Name $'\t' Event $'\t' Date $'\t' Platform $'\t' Environment $'\t' Application > ${tmp_dir}/eventResult.txt 
printf "%15s | %15s | %25s | %15s | %15s | %15s | %15s | %20s\n" Instance-ID Region Name Event Date Platform Environment Application > ${tmp_dir}/eventResult.txt
for rgn in ${aws_region_array[@]}; do
ec2-describe-instance-status -O ${AK} -W ${SAK}  --region ${rgn} | grep -B4 'EVENT' | grep -v 'SYSTEMSTATUS' | grep -v 'INSTANCESTATUS' | grep -v '\-\-' | awk 'NR%2==1 {prev=$0} NR%2==0 {print prev ": " $0} END {if (NR%2==1) {print $0 ":"}}' | grep -v Completed | grep -v Canceled > ${tmp_dir}/rawInfo.txt
	for((i=1; i<=${date_range}; i++)); do  
		dt=$(date "+%Y-%m-%d" -d "$i days")
		cat ${tmp_dir}/rawInfo.txt | grep ${dt} > ${tmp_dir}/loopInfo.txt
		instInRange=$(cat ${tmp_dir}/loopInfo.txt | awk '{print $2}')
		for each in ${instInRange}; do 
			ec2-describe-instances ${each} -O ${AK} -W ${SAK}  --region ${rgn} > ${tmp_dir}/indiInstaInfo.txt
			tg_na=$(cat ${tmp_dir}/indiInstaInfo.txt | grep '^TAG' | grep ${each} | grep -w -i 'Name' | awk '{$1=$2=$3=$4=""; print $0}')
			tg_pl=$(cat ${tmp_dir}/indiInstaInfo.txt | grep '^TAG' | grep ${each} | grep -w -i 'Platform' | awk '{$1=$2=$3=$4=""; print $0}')
			tg_en=$(cat ${tmp_dir}/indiInstaInfo.txt | grep '^TAG' | grep ${each} | grep -w -i 'Environment' | awk '{$1=$2=$3=$4=""; print $0}')
			tg_ap=$(cat ${tmp_dir}/indiInstaInfo.txt | grep '^TAG' | grep ${each} | grep -w -i 'Application' | awk '{$1=$2=$3=$4=""; print $0}')
			ev_in_st=$(cat ${tmp_dir}/loopInfo.txt | grep ${each} | grep instance-stop)
			ev_in_rt=$(cat ${tmp_dir}/loopInfo.txt | grep ${each} | grep instance-retirement)
			ev_in_mt=$(cat ${tmp_dir}/loopInfo.txt | grep ${each} | grep system-maintenance)
			ev_in_sr=$(cat ${tmp_dir}/loopInfo.txt | grep ${each} | grep system-reboot)
			ev_in_ir=$(cat ${tmp_dir}/loopInfo.txt | grep ${each} | grep instance-reboot)
			ev_rg=$(cat ${tmp_dir}/loopInfo.txt | awk '{print $3}')
			if [ ! -z "${ev_in_st}" ]; then
				ev_st=instance-stop
			elif [ ! -z "${ev_in_rt}" ]; then
				ev_st=instance-retirement
			elif [ ! -z "${ev_in_mt}" ]; then
				ev_st=system-maintenance
			elif [ ! -z "${ev_in_sr}" ]; then
				ev_st=system-reboot
			elif [ ! -z "${ev_in_ir}" ]; then
				ev_st=instance-reboot
			fi

			#echo -e ${each} $'\t' ${ev_rg} $'\t' ${tg_na} $'\t' ${ev_st} $'\t' ${dt} $'\t' ${tg_pl} $'\t' ${tg_en} $'\t' ${tg_ap} >> ${tmp_dir}/eventResult.txt
			printf "%15s | %15s | %25s | %15s | %15s | %15s | %15s | %20s\n" ${each} ${ev_rg} ${tg_na} ${ev_st} ${dt} ${tg_pl} ${tg_en} ${tg_ap} >> ${tmp_dir}/eventResult.txt
		done
		#echo '' > ${tmp_dir}/loopInfo.txt
	done
done
RR_QTY=$(cat ${tmp_dir}/eventResult.txt | grep -v "Instance-ID" | wc -l)

if [ "$RR_QTY" -gt 0 ]; then
	echo -e "$RR_QTY maintenance event(s) in next ${date_range} days \n" >> ${tmp_dir}/FneventResult.xls
	cat ${tmp_dir}/eventResult.txt >> ${tmp_dir}/FneventResult.xls
else
	echo -e "No maintenance events in next $1 days for $account\n" >> ${tmp_dir}/FneventResult.xls
fi
}

if [ "$#" -gt 1 ]
then  EMAIL_ID1="$2"
else EMAIL_ID1="$EMAIL_ID"
fi

echo -e "From:$EMAIL_FROM" > ${tmp_dir}/FneventResult.xls
echo -e "To:$EMAIL_ID1" >> ${tmp_dir}/FneventResult.xls
echo -e "Subject: $SUBJECT" >> ${tmp_dir}/FneventResult.xls
echo -e "Content-Type: text/plain" >> ${tmp_dir}/FneventResult.xls
echo -e "\n" >> ${tmp_dir}/FneventResult.xls

echo -e Date: `date +%F` >> ${tmp_dir}/FneventResult.xls

for account in ${aws_account_array[@]}; do

if [ -f ${tmp_dir}/rawInfo.txt ]; then
	echo '' > ${tmp_dir}/rawInfo.txt
fi 

# Add more elif statements if you added any new account to aws_account_array array
	if [ "$account" == "VIDEOLOGY" ]; then
		AK="AKIAIFVGUARTUV6HPHTQ"
		SAK="2nYqGL7ehSMkugZX3gl/TtMofQ+PzKKHhTE/uynE"
	elif [ "$account" == "LMN" ]; then
		AK="AKIAJGCNJXKN7NPIQSOQ"
		SAK="n/QbNZpu8kwnP98u8PjYHX8rCEjsDl/BYcPk6Fa5"
	elif [ "$account" == "VIDEOLOGYDEV" ]; then
		AK="AKIAIEGEZTXTZ5HIMCPA"
		SAK="q38ua+3Z5zwERt/AYSsBacFxwuLJhGB2ptr/i6eh"	
	fi
	#Print the Account Name to the FneventResult file
	 
	echo '' >> ${tmp_dir}/FneventResult.xls
	echo '' >> ${tmp_dir}/FneventResult.xls
	echo -e "===================================Account Wise Event Information: $account ===================================" >> ${tmp_dir}/FneventResult.xls
	echo '' >> ${tmp_dir}/FneventResult.xls
	echo '' >> ${tmp_dir}/FneventResult.xls
	# Call the funciton in the account loop to get the data
	event
done




echo -e "From:$EMAIL_FROM" > ${tmp_dir}/eventEmail.txt
echo -e "To:$EMAIL_ID1" >> ${tmp_dir}/eventEmail.txt
echo -e "Subject: $SUBJECT" >> ${tmp_dir}/eventEmail.txt
echo -e "Content-Type: text/plain" >> ${tmp_dir}/eventEmail.txt
echo -e "\n" >> ${tmp_dir}/eventEmail.txt
#cat ${tmp_dir}/FneventResult.xls >> ${tmp_dir}/eventEmail.txt

#mail -s "$SUBJECT" $EMAIL_ID1 < all-rr-events.txt
/usr/sbin/sendmail -t < ${tmp_dir}/FneventResult.xls