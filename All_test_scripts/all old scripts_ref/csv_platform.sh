#!/bin/bash
echo "Please specify the path of csv file"
read opt
a=0
if [ -e "$opt" ] ;  then
echo "csv file found..."
while [ $a -ne 1 ] ;do
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
                
                        ec2-describe-instances  --region ${rgn} -O ${AK} -W ${SAK} >> /tmp/output
done
done
a=1
done
if [ -e /tmp/output ] ; then
echo "Populating the CSV file Now"
sed -i  's/\t/|/g' ${opt}
 cat ${opt} | awk -F "|" '{print $1}' | while read line ; do cat /tmp/output  | grep $line | grep -w "Platform" | awk '{print $3}' ; done | while read line ; do cat  ${opt} | grep $line ; done  > /tmp/inst1
 cat /tmp/inst1 | while read line ; do echo -ne $line ; cat output | grep `echo "$line"  | cut -d "|" -f1` | grep "TAG" | grep -w "Platform" | awk -F "\t" '{print "|"$5}'; done > /tmp/with_tag
 diff --changed-group-format='%<' --unchanged-group-format='' ${opt} /tmp/inst1  >> /tmp/with_tag
 sed -i 's/|/\t/g' with_tag
 echo "Please find the output in file /tmp/with_tag"
else
echo "INstance information was failed to download please try again"
fi
else
echo "csv file  Not present please create it"
fi

