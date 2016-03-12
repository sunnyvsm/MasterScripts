#!/bin/bash

#export EC2_HOME=/usr/local/share/ec2_tools
#export JAVA_HOME=/usr/lib/jvm/java
#export PATH=$EC2_HOME/bin:$JAVA_HOME/bin:$PATH
echo -e  "Please provide the argument in form \n \033[1msh script.sh <days> <mail-id>\033[0m"
sleep 1
EMAIL_FROM="no.reply@videologygroup.com"
SUBJECT="Regionwise information about Scheduled Instance Reboots and Retirement with Platform"
jiraAuth1="<username>"
jiraAuth2="<password>"

if [ "$#" -eq 2 ]
then  EMAIL_ID1="$2"
else
echo "You had not provided correct argument... exiting now"
exit
fi

if ! type -p ec2-describe-instance-status; then
        echo "Install Ec2 Command Line tool"
        exit
fi

if ! type -p java; then
        echo "Install java"
        exit
fi

#Declare the temporary directory location
tmp_dir=./event_dir
mkdir -p $tmp_dir

#Please add region names if I forgot to add to the array
aws_region_array=(eu-west-1 sa-east-1 us-east-1 ap-northeast-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2)
#aws_region_array=(us-east-1)

#Add account names to the array
aws_account_array=(VIDEOLOGY LMN VIDEOLOGYDEV)
#aws_account_array=(VIDEOLOGY)

date_range=$1

event () {
for rgn in ${aws_region_array[@]}; do
ec2-describe-instance-status -O ${AK} -W ${SAK}  --region ${rgn} | grep -B4 'EVENT' | grep -v 'SYSTEMSTATUS' | grep -v 'INSTANCESTATUS' | grep -v '\-\-' | awk 'NR%2==1 {prev=$0} NR%2==0 {print prev ": " $0} END {if (NR%2==1) {print $0 ":"}}' | grep -v Completed | grep -v Canceled > ${tmp_dir}/rawInfo.txt
        for((i=1; i<=${date_range}; i++)); do
                dt=$(date "+%Y-%m-%d" -d "$i days")
                cat ${tmp_dir}/rawInfo.txt | grep ${dt} > ${tmp_dir}/loopInfo.txt
                instInRange=$(cat ${tmp_dir}/loopInfo.txt | awk '{print $2}')
                for each in ${instInRange}; do
                        ec2-describe-instances ${each} -O ${AK} -W ${SAK}  --region ${rgn} > ${tmp_dir}/indiInstaInfo.txt
                        tg_na=$(cat ${tmp_dir}/indiInstaInfo.txt | grep '^TAG' | grep ${each} | grep -w -i 'Name' | awk '{$1=$2=$3=$4=""; print $0}'| sed 's/ //g')
                        tg_pl=$(cat ${tmp_dir}/indiInstaInfo.txt | grep '^TAG' | grep ${each} | grep -w -i 'Platform' | awk '{$1=$2=$3=$4=""; print $0}' | sed 's/ //g')
                        tg_en=$(cat ${tmp_dir}/indiInstaInfo.txt | grep '^TAG' | grep ${each} | grep -w -i 'Environment' | awk '{$1=$2=$3=$4=""; print $0}'|sed 's/ //g')
                        tg_ap=$(cat ${tmp_dir}/indiInstaInfo.txt | grep '^TAG' | grep ${each} | grep -w -i 'Application' | awk '{$1=$2=$3=$4=""; print $0}'| sed 's/ //g')
                        ev_in_st=$(cat ${tmp_dir}/loopInfo.txt | grep ${each} | grep instance-stop | sed 's/ //g')
                        ev_in_rt=$(cat ${tmp_dir}/loopInfo.txt | grep ${each} | grep instance-retirement | sed 's/ //g')
                        ev_in_mt=$(cat ${tmp_dir}/loopInfo.txt | grep ${each} | grep system-maintenance | sed 's/ //g')
                        ev_in_sr=$(cat ${tmp_dir}/loopInfo.txt | grep ${each} | grep system-reboot | sed 's/ //g')
                        ev_in_ir=$(cat ${tmp_dir}/loopInfo.txt | grep ${each} | grep instance-reboot | sed 's/ //g')
                        ev_rg=$(cat ${tmp_dir}/loopInfo.txt | grep ${each} | awk '{print $14}' | sed 's/ //g')
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
                         curl --silent -D- -u "$jiraAuth1":"$jiraAuth2" -X GET -H "Content-Type: application/json" "https://videologygroup.atlassian.net:443/rest/api/2/search?jql=summary~\"AWS%20instance-event:%20${ev_st}%20for%${each}%20with%20name-tag%20${tg_na}%20in%20${rgn}%20on%20${dt}\"&fields=summary" -o summarynew.txt

                       summaryString=`cat summarynew.txt`;sumStr=`echo ${summaryString##*summary} | awk -F\" '{ print $3 }' | grep "$each" | grep "$env_st" | grep "$dt"`

                       if [ -z "$sumStr" ]; then

                         # Create JSON file
                         echo -e "{ \n" > ./issue_create.json
                         echo -e "  \"fields\":{\n" >> ./issue_create.json
                         echo -e "   \"project\":\n" >> ./issue_create.json
                         echo -e "    {\n" >> ./issue_create.json
                         echo -e "     \"key\": \"TIOT\"\n" >> ./issue_create.json
                         echo -e "   },\n" >> ./issue_create.json
                         echo -e "  \"summary\": \"AWS instance-event: ${ev_st} for ${each} with name-tag ${tg_na} in ${rgn} on ${dt}\",\n" >> ./issue_create.json
                         echo -e "  \"description\": \"Platform: ${tg_pl}, Environment: ${tg_en},  Application: ${tg_ap}\",\n" >> ./issue_create.json
                         echo -e "  \"issuetype\":{\n" >> ./issue_create.json
                         echo -e "     \"name\":\"Task\"\n" >> ./issue_create.json
                         echo -e "   },\n" >> ./issue_create.json
                         echo -e "   \"priority\":{\n" >> ./issue_create.json
                         echo -e "     \"name\":\"High\"\n" >> ./issue_create.json
                         echo -e "   },\n" >> ./issue_create.json
                         echo -e "  \"components\":[{\n" >> ./issue_create.json
                         echo -e "     \"name\":\"Infrastructure\"\n" >> ./issue_create.json
                         echo -e "   }]\n" >> ./issue_create.json
                         echo -e "  }\n" >> ./issue_create.json
                         echo -e " }\n" >> ./issue_create.json

                         curl -D- -u "$jiraAuth1":"$jiraAuth2" -X POST --data-binary "@issue_create.json" -H "Content-Type: application/json" https://videologygroup.atlassian.net:443/rest/api/2/issue/> newticket_details
						 cat newticket_details | grep "HTTP/1.1 201 Created"
						 if [ $? != 0 ]; then 
							ticket_status="Jira credential issue: Ticket not created"
						else
                         ticket_num=`cat newticket_details | tail -1 |sed -e 's/.*\(TIOT-[0-9]\{1,5\}\).*/\1/'`
                         ticket_url="https://videologygroup.atlassian.net/browse/$newticket_num"
						 fi
					  else
                        ticket_num=`cat summarynew.txt | sed -e 's/.*\(TIOT-[0-9]\{1,5\}\).*/\1/'`
                        ticket_status="https://videologygroup.atlassian.net/browse/$ticket_num"

                      fi

                                                        echo -e "<td>${each}</td><td>${rgn}</td><td>${tg_na}</td><td>${ev_st}</td><td>${dt}</td><td>${tg_pl}</td><td>${tg_en}</td><td>${tg_ap}</td><td>${ticket_status}</td></tr>" >> ${tmp_dir}/eventResult.txt

                       echo -e "${each}" >> ${tmp_dir}/count.txt
                       #printf "%15s | %15s | %30s | %15s | %15s | %15s | %15s | %20s\n" ${each} ${ev_rg} ${tg_na} ${ev_st} ${dt} ${tg_pl} ${tg_en} ${tg_ap} >> ${tmp_dir}/eventResult.txt
                done
                #echo '' > ${tmp_dir}/loopInfo.txt
        done
done
RR_QTY=$(cat ${tmp_dir}/count.txt | wc -l)

if [ "$RR_QTY" -gt 0 ]; then
        echo -e "<h3>$RR_QTY maintenance event(s) in next ${date_range} days \n</h3>" >> ${tmp_dir}/FneventResult.txt
        sed -i '1i <table border="1" style="width:100%"><tr><td><b>Instance-ID</b></td><td><b>Region</b></td><td><b>Name</b></td><td><b>Event</b></td><td><b>Date</b></td><td><b>Platform</b></td><td><b>Environment</b></td><td><b>Application</b></td><td><b>Jira Link</b></td></tr><tr>' ${tmp_dir}/eventResult.txt
        cat ${tmp_dir}/eventResult.txt >> ${tmp_dir}/FneventResult.txt
        echo -e "</table>" >> ${tmp_dir}/FneventResult.txt
        echo '' > ${tmp_dir}/eventResult.txt
        cat /dev/null > ${tmp_dir}/count.txt
else
        echo -e "No maintenance events in next ${date_range} days for $account\n" >> ${tmp_dir}/FneventResult.txt
fi
}

echo -e "From:$EMAIL_FROM" > ${tmp_dir}/FneventResult.txt
echo -e "To:$EMAIL_ID1" >> ${tmp_dir}/FneventResult.txt
echo -e "Subject: $SUBJECT" >> ${tmp_dir}/FneventResult.txt
echo -e "Content-Type: text/html" >> ${tmp_dir}/FneventResult.txt
echo -e "\n" >> ${tmp_dir}/FneventResult.txt

echo -e "<h2>Date: `date +%F`</h2>" >> ${tmp_dir}/FneventResult.txt

for account in ${aws_account_array[@]}; do

if [ -f ${tmp_dir}/rawInfo.txt ]; then
        echo '' > ${tmp_dir}/rawInfo.txt
fi

# Add more elif statements if you added any new account to aws_account_array array
        if [ "$account" == "VIDEOLOGY" ]; then
                aws_cfg=/home/vlg/etc/aws/videology.cfg
                source $aws_cfg
        elif [ "$account" == "LMN" ]; then
                aws_cfg=/home/vlg/etc/aws/lmn.cfg
                source $aws_cfg
        elif [ "$account" == "VIDEOLOGYDEV" ]; then
                aws_cfg=/home/vlg/etc/aws/videologydev.cfg
                source $aws_cfg
        fi
        AK="$aws_access_key_id"
        SAK="$aws_secret_access_key"

        #Print the Account Name to the FneventResult file

        echo '' >> ${tmp_dir}/FneventResult.txt
        echo '' >> ${tmp_dir}/FneventResult.txt
        echo -e "<h3>Account Wise Event Information: $account </h3>" >> ${tmp_dir}/FneventResult.txt
        echo '' >> ${tmp_dir}/FneventResult.txt
        echo '' >> ${tmp_dir}/FneventResult.txt
        # Call the funciton in the account loop to get the data
        event
done

acc_Count="3"
no_Maint_Count=`cat ${tmp_dir}/FneventResult.txt | grep -ic 'No Maintenance'`

if [ "$no_Maint_Count" -lt "$acc_Count" ]; then
  /usr/sbin/sendmail -t < ${tmp_dir}/FneventResult.txt
fi
