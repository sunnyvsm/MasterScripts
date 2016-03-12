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

        for rgn in ${aws_region_array[@]}; do
                echo "Downloading the instance information for region ${rgn}"
                        ec2-describe-instances  --region ${rgn} -O ${AK} -W ${SAK} >> /tmp/output_${account}
done
if [ -e "/tmp/output_${account}" ] ; then
clear
echo "Gathering Instances with INcorrect Tagging"
cat /tmp/output_${account} | grep "TAG" | grep -w "Platform" | grep -v "BI\|Data\|Eliza\|Layla\|Lucy\|Maya\|Optimization\|RnD\|Systems" | sort -u | awk -F "\t" '{print $3}' | while read line ; do cat /tmp/output_${account} | grep "$line" | grep -w "INSTANCE\|Platform" | sort -u  ; done | sed 's/\t/|/g' | awk -F "|" '{if ( $1 == "INSTANCE" ) print $2,$10 ; else if ($1 == "TAG") print $5"|"}' | xargs | sed 's/|/\n/g'| sed 's/^ i/i/'|  sed 's/ /\t/g' | sed '/i-*/!d' | sed '1i INSTANCE_ID\tINSTANCE_TYPE\tPLATFORM' >> /tmp/Incorrectly_tagging_${account}.xls
 echo "Please find the output in file Incorrectly_tagging"
else
echo "INstance information was failed to download please try again"
fi
done
