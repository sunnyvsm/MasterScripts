#!/bin/bash
tmp_dir=/tmp/inst_tag_info
if [ -d ${tmp_dir} ]; then 
echo " "
else
echo "Creating directory"
mkdir ${tmp_dir}
fi

aws_region_array=(eu-west-1 sa-east-1 us-east-1 ap-northeast-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2)
#aws_region_array=(us-east-1)
aws_account_array=(LMN VIDEOLOGY VIDEOLOGYDEV)
for account in ${aws_account_array[@]}; do

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
	
		for rgn in ${aws_region_array[@]}; do
		
		ec2-describe-instances  --region ${rgn} -O ${AK} -W ${SAK} |  grep -v "shutting-down" | grep -v "stopped" | grep -v "terminated"  >> ${tmp_dir}/${account}_${rgn}_active_data.txt
			
			cat ${tmp_dir}/${account}_${rgn}_active_data.txt | grep "TAG"| grep  -w "Platform" |grep -v -i  "lucy\|Eliza\|Layla\|Maya" | awk -F "\t" '{print $5}' | sort -u  | while read line ; do cat ${tmp_dir}/${account}_${rgn}_active_data.txt | grep -w "Platform"| grep "$line\$" | awk -F "\t" '{print $3}'| sed "1i $line" ; done | sed 's/^[A-Z].*/\n&/' >> ${tmp_dir}/${account}_${rgn}_platformwise_instances.txt
			
		#cat ${tmp_dir}/${account}_${rgn}_active_data.txt | grep "TAG"| grep  -w "Platform" |grep -v -i  "lucy\|Eliza\|Layla\|Maya" | awk -F "\t" '{print $5}' | sort -u  | while read line ; do cat ${tmp_dir}/${account}_${rgn}_active_data.txt| grep -w "Platform"| grep "$line" | awk -F "\t" '{print $3}'| sed "1i $line" ; done | sed 's/^[A-Z].*/\n&/'>> ${tmp_dir}/${account}_${rgn}_platformwise_instances.txt 
		
		echo " " >> ${tmp_dir}/${account}_${rgn}_platformwise_instances.txt
		echo "Other Platform" >> ${tmp_dir}/${account}_${rgn}_platformwise_instances.txt
		
				
		cat ${tmp_dir}/${account}_${rgn}_active_data.txt | grep -v "RESERVATION\|PRIVATEIPADDRESS\|NICASSOCIATION\|NIC\|BLOCKDEVICE\|GROUP"|sed -E  's/^.*\s(i\-[0-9a-z]{1,9}).*/\1/' | sort -u  | sort >> ${tmp_dir}/${account}_${rgn}_total_ids.txt
		
		
		 cat ${tmp_dir}/${account}_${rgn}_active_data.txt  | grep "TAG"| grep  -w "Platform" |grep -v -i  "lucy\|Eliza\|Layla\|Maya"  | awk -F "\t" '{print $3}' | sort -u |sort  >> ${tmp_dir}/${account}_${rgn}_platform_ids.txt		 
		 
		 cat ${tmp_dir}/${account}_${rgn}_active_data.txt | grep -i  tag |grep -i  "lucy\|Eliza\|Layla\|Maya" | awk -F "\t" '{print $3}' | sort -u | sort   >>${tmp_dir}/${account}_${rgn}_ly-my-lu-el-ids
		
		
		#sort arp_tot_ids > sorted.arp_tot
		#sort all_lyla_ids > sorted.lyla
		diff --changed-group-format='%<' --unchanged-group-format='' ${tmp_dir}/${account}_${rgn}_total_ids.txt ${tmp_dir}/${account}_${rgn}_ly-my-lu-el-ids | sort >> ${tmp_dir}/${account}_${rgn}_all_nonly-my-lu-el-ids
		
		diff --changed-group-format='%<' --unchanged-group-format='' ${tmp_dir}/${account}_${rgn}_all_nonly-my-lu-el-ids ${tmp_dir}/${account}_${rgn}_platform_ids.txt >> ${tmp_dir}/${account}_${rgn}_platformwise_instances.txt
		
		
		#cat ${tmp_dir}/${account}_${rgn}_active_data.txt | grep "INSTANCE" | awk -F "\t" '{print $2}' >> ${tmp_dir}/${account}_${rgn}_active_ids.txt
				
		#cat ${tmp_dir}/${account}_${rgn}_active_ids.txt | while read line ; do cat ${tmp_dir}/${account}_${rgn}_active_data.txt |  grep $line | grep -w Platform | awk -F "\t" '{print $3}' ;done >> ${tmp_dir}/${account}_${rgn}_pltfrm_ids_.txt
						
		done
done



























ec2-describe-instances  --region us-east-1 -O AKIAIFVGUARTUV6HPHTQ -W 2nYqGL7ehSMkugZX3gl/TtMofQ+PzKKHhTE/uynE  > opt
cat opt |grep "INSTANCE" | grep -v "shutting-down" | grep -v "stopped" | grep -v "terminated" | awk -F "\t" '{print $2}'  > all data
cat all_data | grep "TAG"| grep -v -i  "lucy\|Eliza\|Layla\|Maya" | grep "Platform" | awk -F "\t" '{print $5}' | sort -u  | while read line ; do cat opt1 | grep "$line" | awk -F "\t" '{print $3}'| sed "1i $line" ; done| sed 's/^[A-Z].*/\n&/'
#cat opt |grep "INSTANCE"| grep -v "shutting-down" | grep -v "stopped" | grep -v "terminated" | awk -F "\t" '{print $2}' > all_ids

		#cat all_ids  | while read line ; do cat opt |  grep $line | grep -w Platform | awk -F "\t" '{print $3}' ;done > all_plt_ids


Eliza
Lucy
Maya
Layla