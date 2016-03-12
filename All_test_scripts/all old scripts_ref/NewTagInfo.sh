#!/bin/bash

emailTo="tmishra.consultant@videologygroup.com"

#Declare the temporary directory location
tmp_dir=/tmp

#Please add region names if I forgot to add to the array
aws_region_array=(us-east-1 us-west-1 us-west-2 eu-west-1 ap-northeast-1 ap-southeast-1 ap-southeast-2 sa-east-1)

#Add account names to the array
aws_account_array=(VIDEOLOGY LMN VIDEOLOGYDEV)

platform_array=(Maya Lucy Eliza Layla)

if [ -f ${tmp_dir}/tagResult.txt ]; then 
	echo '' > ${tmp_dir}/tagResult.txt
fi 

data ()
{
for rgn in ${aws_region_array[@]}; do
	if [ -f ${tmp_dir}/list1.txt ]; then
		echo '' > ${tmp_dir}/list1.txt
	fi 

	if [ -f ${tmp_dir}/list2.txt ]; then
		echo '' > ${tmp_dir}/list2.txt
	fi 
	
	if [ -f ${tmp_dir}/instanceinfo.txt ]; then
		echo '' > ${tmp_dir}/instanceinfo.txt
	fi 
	
	if [ -f ${tmp_dir}/tmp_list2.txt ]; then
		echo '' > ${tmp_dir}/tmp_list2.txt
	fi 

	ec2-describe-instances --region ${rgn} -O ${AK} -W ${SAK} >> ${tmp_dir}/instanceinfo.txt
	
	for each in $(cat ${tmp_dir}/instanceinfo.txt | grep "^INSTANCE" | awk {'print $2'}); do 

		plf_cmd=`cat ${tmp_dir}/instanceinfo.txt| grep $each | grep "^TAG" | grep -w "Platform"`
		echo ${plf_cmd}
		if [ -z "${plf_cmd}" ]; then 
			echo ${each} >> ${tmp_dir}/list1.txt
		else
			echo -e "${plf_cmd}" >> ${tmp_dir}/list2.txt
		fi
	done
	
	for pf in ${platform_array[@]}; do
		sed -i "/$pf/d" ${tmp_dir}/list2.txt  
	done
	
	tgCount=$(cat ${tmp_dir}/list2.txt | awk {'print $5'} | sort | uniq --repeated)
	echo ${tgCount}
	for tg in ${tgCount[@]}; do
		tgRes=$(cat ${tmp_dir}/list2.txt | grep ${tg} | awk '{ print $3 }')
		echo ${tgRes}
		if [ ! -z "${tgRes}" ]; then
			echo -e "Platform : ${tg}" >> ${tmp_dir}/tmp_list2.txt
			echo ${tgRes} >> ${tmp_dir}/tmp_list2.txt
		fi
	done
			
	read1=$(cat ${tmp_dir}/tmp_list2.txt)
	read2=$(cat ${tmp_dir}/list1.txt)
	
	if [ x"${read1}" = x ] && [ x"{$read2}" = x ]; then
		echo '' 
	elif [ x"${read1}" = x ]; then 
		echo -e "===============Tagging Information for Region: ${rgn}" >> ${tmp_dir}/tagResult.txt
		echo -e "List of Instances without having Tag Platform." >> ${tmp_dir}/tagResult.txt
		cat ${tmp_dir}/list1.txt >> ${tmp_dir}/tagResult.txt
	elif [ x"${read2}" = x ]; then
		echo -e "===============Tagging Information for Region: ${rgn}" >> ${tmp_dir}/tagResult.txt
		echo -e "List of Instance with Tag Platform and their details" >> ${tmp_dir}/tagResult.txt
		cat ${tmp_dir}/tmp_list2.txt >> ${tmp_dir}/tagResult.txt
	else 
		echo -e "===============Tagging Information for Region: ${rgn}" >> ${tmp_dir}/tagResult.txt
		echo -e "List of Instances without having Tag Platform." >> ${tmp_dir}/tagResult.txt
		cat ${tmp_dir}/list1.txt >> ${tmp_dir}/tagResult.txt
		echo -e "===============Tagging Information for Region: ${rgn}" >> ${tmp_dir}/tagResult.txt
		echo -e "List of Instance with Tag Platform and their details" >> ${tmp_dir}/tagResult.txt
		cat ${tmp_dir}/tmp_list2.txt >> ${tmp_dir}/tagResult.txt		
	fi
done
}

#Set the AWS access key and Secrete keys to their relevant Accounts
for account in ${aws_account_array[@]}; do

if [ -f ${tmp_dir}/tagCount.txt ]; then
	echo '' > ${tmp_dir}/tagCount.txt
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
	#Print the Account Name to the tagResult file
	echo '' >> ${tmp_dir}/tagResult.txt
	echo '' >> ${tmp_dir}/tagResult.txt
	echo -e "===================================Account Wise Taging Information: $account ===================================" >> ${tmp_dir}/tagResult.txt
	echo '' >> ${tmp_dir}/tagResult.txt
	echo '' >> ${tmp_dir}/tagResult.txt
	# Call the funciton in the account loop to get the data
	data
done

mail -s "Account Wise Tag Information" ${emailTo} < ${tmp_dir}/tagResult.txt