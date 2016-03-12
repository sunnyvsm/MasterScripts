#!/bin/bash

#Declare the temporary directory location
tmp_dir=/tmp/res_info_dir

#Please add if I forgot to add any instance type to the array
instance_type_array=(t2.micro  t2.small  t2.medium  m3.medium  m3.large  m3.xlarge  m3.2xlarge c3.large  c3.xlarge  c3.2xlarge  c3.4xlarge  c3.8xlarge r3.large  r3.xlarge  r3.2xlarge  r3.4xlarge  r3.8xlarge i2.xlarge  i2.2xlarge  i2.4xlarge  i2.8xlarge  hs1.8xlarge g2.2xlarge m1.small  m1.medium  m1.large  m1.xlarge c1.medium  c1.xlarge  cc2.8xlarge m2.xlarge  m2.2xlarge  m2.4xlarge  cr1.8xlarge hi1.4xlarge cg1.4xlarge t1.micro)

#Please add region names if I forgot to add to the array
aws_region_array=(eu-west-1 sa-east-1 us-east-1 ap-northeast-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2)

#Add account names to the array
aws_account_array=(LMN VIDEOLOGY VIDEOLOGYDEV)

platforms_array=(Windows Linux\/UNIX)

#Create the temporary directory if not exists. 
if [ ! -d ${tmp_dir} ]; then
	mkdir -p ${tmp_dir}
fi

#Clear the previous result.txt file
if [ -f ${tmp_dir}/result.txt ]; then
	echo '' > ${tmp_dir}/result.txt
fi

# Function to gather data for individual AWS account 
data_region_wise ()
{
# Clear the result file before process if it exits from earlier
if [ -f ${tmp_dir}/${account}_result.txt ];then
	echo '' > ${tmp_dir}/${account}_result.txt
fi
#Loop for regions. 
for rgn in ${aws_region_array[@]}; do
	echo '' >> ${tmp_dir}/${account}_result.txt
	#Print the region name to the result file
	echo -e "############$rgn#############" >> ${tmp_dir}/${account}_result.txt
	echo '' >> ${tmp_dir}/${account}_result.txt

	#Print the reserved instances info of the region to a file
	ec2-describe-reserved-instances --region ${rgn} -O ${AK} -W ${SAK} > ${tmp_dir}/res_info_region.txt
	# Verify if any reserved information is there or not, else print "Sorry no data available for the region"
	if [ "$(grep -v "retired" < /tmp/res_info_dir/res_info_region.txt | wc -l)" -gt 1 ]; then 
		# Loop for the platforms to grep their count
		for platforms in ${platforms_array[@]}; do 
			# Loop for the instance type to grep their count 
			for instancetype in ${instance_type_array[@]}; do
				# Store the reserved instance numbers to a variable
				count=$(cat ${tmp_dir}/res_info_region.txt | grep -E "${instancetype}.*${platforms}" | grep -v "RECURRING-CHARGE" | grep -v "retired" | awk {'print $(NF-7)'})
				# Add the variable array to get the total number of reserved instances based on platform and region wise
				for i in ${count[@]};do 
					ins_count=$((ins_count+i))
				done
				# Print the Total count to a file if the value is not null
				if [ ! -z "${ins_count}" ]; then
				echo ${instancetype}$'\t'${ins_count}$'\t'${rgn}$'\t'${platforms} >> ${tmp_dir}/${account}_result.txt
				fi
				# Reset the value of the variable in the above loop
				unset ins_count
			done
		done
	else 
		echo "Sorry no data available for the region" >> ${tmp_dir}/${account}_result.txt
	fi
done
}

#Set the AWS access key and Secrete keys to their relevant Accounts
for account in ${aws_account_array[@]}; do
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
	#Print the Account Name to the result file
	echo '' >> ${tmp_dir}/result.txt
	echo '' >> ${tmp_dir}/result.txt
	echo -e "===================================Region wise data for the account $account===================================" >> ${tmp_dir}/result.txt
	echo '' >> ${tmp_dir}/result.txt
	echo '' >> ${tmp_dir}/result.txt
	# Call the funciton in the account loop to get the data
	data_region_wise
	# Read the generated result file from the above function and append it to the final result file. 
	cat ${tmp_dir}/${account}_result.txt >> ${tmp_dir}/result.txt
done

# Below section belongs to get the total count for world wide data platform wise and account wise
for account in ${aws_account_array[@]}; do
	echo '' >> ${tmp_dir}/result.txt
	echo '' >> ${tmp_dir}/result.txt
	echo -e "===================================WORLDWIDE data for the account $account===================================" >> ${tmp_dir}/result.txt
	echo '' >> ${tmp_dir}/result.txt
	echo '' >> ${tmp_dir}/result.txt
	if [ "$(grep -v '^$\|^\s*\#' ${tmp_dir}/${account}_result.txt | grep -v "Sorry" | wc -l)" -gt 1 ]; then
	# Loop for platforms to get the count 
		for platforms in ${platforms_array[@]}; do
			# Loop for instance type to get their count
			for instancetype in ${instance_type_array[@]}; do 
				# Grep the instance count and store the counts to a variable. 
				count=$(cat ${tmp_dir}/${account}_result.txt | grep -E "${instancetype}.*${platforms}" | awk {'print $2'})
					# Loop to add the count from the array stored in the above variable
					for i in ${count[@]};do 
						ins_count=$((ins_count+i))
					done
					# Print the value to the file if the value is not null
					if [ ! -z "${ins_count}" ]; then
						echo ${instancetype}$'\t'${ins_count}$'\t'"WORLDWIDE"$'\t'${platforms} >> ${tmp_dir}/result.txt
					fi
					# Reset the value of the variable in the above loop 
					unset ins_count
			done
		done
	else
		echo "Sorry no data available for the account" >> ${tmp_dir}/result.txt
	fi
done
## Finally a file named result.txt will be generated in the temporary directory declared in the first of the script. Download that and send it to the client. 