#!/bin/bash
tmp_dir=/tmp/no_prd_srv
if [ -d ${tmp_dir} ]; then 
echo " "
else
echo "Creating directory"
mkdir ${tmp_dir}
fi

aws_region_array=(eu-west-1 sa-east-1 us-east-1 ap-northeast-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2)
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
done

	for rgn in ${aws_region_array[@]}; do
			ec2-describe-instances  --region ${rgn} -O ${AK} -W ${SAK} >> ${tmp_dir}/${account}_${rgn}_all_data.txt
					sed -i 's/\t/|/g' ${tmp_dir}/${account}_${rgn}_all_data.txt		
			 cat ${tmp_dir}/${account}_${rgn}_all_data.txt  | grep "INSTANCE" | grep -v "shutting-down" | grep -v "stopped" | grep -v "terminated" | awk -F "|" '{print $2}' >> ${tmp_dir}/${account}_${rgn}_all_data_ids.txt
			 cat ${tmp_dir}/${account}_${rgn}_all_data.txt| grep "TAG" | awk -F "|" '{if (($4=="Environment") && ($5 =="Production")) print $3}'  >> ${tmp_dir}/${account}_${rgn}_all_prod_ids.txt
			 diff --changed-group-format='%<' --unchanged-group-format='' ${tmp_dir}/${account}_${rgn}_all_data_ids.txt  ${tmp_dir}/${account}_${rgn}_all_prod_ids.txt >> ${tmp_dir}/${account}_${rgn}_all_non_prod_ids.txt
			 cat ${tmp_dir}/${account}_${rgn}_all_non_prod_ids.txt | while read line ; do cat ${tmp_dir}/${account}_${rgn}_all_data.txt | grep $line ; done >> ${tmp_dir}/${account}_${rgn}_all_non_production_data.txt
			 count=`wc -l ${tmp_dir}/${account}_${rgn}_all_non_production_data.txt | awk '{print $1}'`
for (( i=1; i<="$count"; i++ )) ; do 
			sed -n "$i"p ${tmp_dir}/${account}_${rgn}_all_non_production_data.txt | awk -F "|" ' {if ($1 =="INSTANCE") print "===================\n" $1,$2,$12,$3,$10}' >> ${tmp_dir}/${account}_${rgn}_output.txt
			sed -n "$i"p ${tmp_dir}/${account}_${rgn}_all_non_production_data.txt | awk -F "|" '{if ($4 == "Name")print $4,$5 ;else print "Name  "}' >> ${tmp_dir}/${account}_${rgn}_output.txt
			sed -n "$i"p ${tmp_dir}/${account}_${rgn}_all_non_production_data.txt | awk -F "|" '{if ($4 == "Platform")print $4,$5 ;else print "Platform  "}' >> ${tmp_dir}/${account}_${rgn}_output.txt
			sed -n "$i"p ${tmp_dir}/${account}_${rgn}_all_non_production_data.txt | awk -F "|" '{if ($4 == "Environment")print $4,$5 ;else print "Environment  "}' >> ${tmp_dir}/${account}_${rgn}_output.txt
			sed -n "$i"p ${tmp_dir}/${account}_${rgn}_all_non_production_data.txt | awk -F "|" '{if ($4 == "Application")print $4,$5 ;else print "Application  "}' >> ${tmp_dir}/${account}_${rgn}_output.txt
	done

done
	
	
	
