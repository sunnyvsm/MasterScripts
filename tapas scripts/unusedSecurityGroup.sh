#/bin/bash

aws_region_array=(eu-west-1 sa-east-1 us-east-1 ap-northeast-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2)
aws_account_array=(VIDEOLOGY LMN)

echo '' > /tmp/Sg_list.txt

for account in ${aws_account_array[@]}; do
echo -e "" >> /tmp/Sg_list.txt
echo -e "" >> /tmp/Sg_list.txt
echo -e "==============Info for the Account ${account} =================" >> /tmp/Sg_list.txt
echo -e "" >> /tmp/Sg_list.txt
echo -e "" >> /tmp/Sg_list.txt

	if [ "$account" == "VIDEOLOGY" ]; then
		pf=default
	elif [ "$account" == "LMN" ]; then
		pf=LMN
	fi
	
	for rgn in ${aws_region_array[@]}; do
	echo -e "" >> /tmp/Sg_list.txt
	echo -e "" >> /tmp/Sg_list.txt
	echo -e "For the Region ${rgn} =================" >> /tmp/Sg_list.txt
	echo -e "" >> /tmp/Sg_list.txt
	echo -e "" >> /tmp/Sg_list.txt
	echo -e GroupID $'\t' GropName >> /tmp/Sg_list.txt
		list=$(eval comm -23  <(aws ec2 describe-security-groups --region ${rgn} --query 'SecurityGroups[*].GroupId'  --output text --profile=${pf} | tr '\t' '\n'| sort) <(aws ec2 describe-instances --region ${rgn} --query 'Reservations[*].Instances[*].SecurityGroups[*].GroupId' --output text --profile=${pf} | tr '\t' '\n' | sort | uniq))
		for gp in ${list[@]}; do 
			gp_name=$(aws ec2 describe-security-groups --region ${rgn} --group-ids ${gp} --output text --profile=${pf} | grep '^SECURITYGROUPS' | sed 's/\t/|/g' | awk -F'|' '{print $4}')
			echo -e  ${gp} $'\t' ${gp_name} >> /tmp/Sg_list.txt
		done
	done
done	