#!/bin/bash
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
echo "Downloading the instance information for Account ${account}"
        for rgn in ${aws_region_array[@]}; do
                
                        ec2-describe-instances  --region ${rgn} -O ${AK} -W ${SAK} >> /tmp/output_${account}
done
echo "Gathering Non-Production Instances"
if [ -e "/tmp/output_${account}" ] ; then
clear

#cat /tmp/output_${account} | grep "TAG" | grep "Environment"  | grep -v Production | awk -F "\t" '{print $3"\t"$5}' > /tmp/nonprod_${account}.xls
#cat /tmp/nonprod_${account}.xls |  while read line ; do echo -ne "$line \t"; cat /tmp/output_${account} | grep `echo "$line"  | awk -F "\t" '{print $1}'` | grep INSTANCE | awk -F "\t" '{print $6}' ; done| sed '1i Instance-ID\tEnvironment\tStatus'  > /tmp/non_prod_status_${account}.xls
#cat /tmp/output_${account} | grep "TAG" | grep "Environment"  | grep -v Production | awk -F "\t" '{print $3"\t"$5}' | sort -u | while read line ; do echo -ne "$line \t"; cat /tmp/output_${account} | grep `echo "$line"  | awk -F "\t" '{print $1}'` | grep INSTANCE | awk -F "\t" '{print $6}' ; done| sed '1i Instance-ID\tEnvironment\tStatus' > nonprod_status_${account}.xls
cat /tmp/output_${account} | grep "TAG" | grep -w "Platform" | grep "Maya" | awk -F "\t" '{print $3}'  | while read aa ; do cat /tmp/output_${account} | grep "$aa" | grep "TAG" | grep "Environment" | grep -v "Production" ; done  | awk -F "\t" '{print $3"\t"$5}' | while read ab ; do echo -ne "$ab \t" ; cat /tmp/output_${account} | grep `echo "$ab" | awk -F "\t" '{print $1}'` | grep "INSTANCE" | awk -F "\t" '{print $6}' ; done  | sed '1i Instance-ID\tEnviroment\tStatus\n' > /tmp/nonprod_status_${account}.xls
 echo "Please find the output in file /tmp/nonprod_status_${account}.xls"
else
echo "INstance information was failed to download please try again"
fi
done
