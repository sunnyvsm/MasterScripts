#!/bin/bash

export EC2_HOME=/usr/local/share/ec2_tools
export JAVA_HOME=/usr/lib/jvm/java
export PATH=$EC2_HOME/bin:$JAVA_HOME/bin:$PATH

EMAIL_FROM="no.reply@videologygroup.com"
EMAIL_ID="devops@videologygroup.com"
EMAIL_ID1=""
SUBJECT="Region wise information about Scheduled Instance Reboots and Retirement with Platform"

if [ "$#" -gt 1 ]
then  EMAIL_ID1="$2"
else EMAIL_ID1="$EMAIL_ID"
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
tmp_dir=/tmp

#Please add region names if I forgot to add to the array
aws_region_array=(eu-west-1 sa-east-1 us-east-1 ap-northeast-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2)

#Add account names to the array
aws_account_array=(VIDEOLOGY LMN VIDEOLOGYDEV)

date_range=$1

event () {
#echo -e Instance-ID $'\t' Region $'\t' Name $'\t\t' Event $'\t\t\t' Date $'\t\t' Platform $'\t' Environment $'\t' Application > ${tmp_dir}/eventResult.txt
#printf "%15s | %15s | %30s | %15s | %15s | %15s | %15s | %20s\n" Instance-ID Region Name Event Date Platform Environment Application > ${tmp_dir}/eventResult.txt
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
                        ev_rg=$(cat ${tmp_dir}/loopInfo.txt | grep ${each} | awk '{print $14}')
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

                        echo -e "<td>${each}</td><td>${rgn}</td><td>${tg_na}</td><td>${ev_st}</td><td>${dt}</td><td>${tg_pl}</td><td>${tg_en}</td><td>${tg_ap}</td></tr>" >> ${tmp_dir}/eventResult.txt
                        echo -e "${each}" >> ${tmp_dir}/count.txt
                        #printf "%15s | %15s | %30s | %15s | %15s | %15s | %15s | %20s\n" ${each} ${ev_rg} ${tg_na} ${ev_st} ${dt} ${tg_pl} ${tg_en} ${tg_ap} >> ${tmp_dir}/eventResult.txt
                done
                #echo '' > ${tmp_dir}/loopInfo.txt
        done
done
RR_QTY=$(cat ${tmp_dir}/count.txt | wc -l)

if [ "$RR_QTY" -gt 0 ]; then
        echo -e "<h3>$RR_QTY maintenance event(s) in next ${date_range} days \n</h3>" >> ${tmp_dir}/FneventResult.txt
        sed -i '1i <table border="1" style="width:100%"><tr><td><b>Instance-ID</b></td><td><b>Region</b></td><td><b>Name</b></td><td><b>Event</b></td><td><b>Date</b></td><td><b>Platform</b></td><td><b>Environment</b></td><td><b>Application</b></td></tr><tr>' ${tmp_dir}/eventResult.txt
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
                source /home/vlg/etc/aws/videology.cfg
        elif [ "$account" == "LMN" ]; then
                source /home/vlg/etc/aws/lmn.cfg
        elif [ "$account" == "VIDEOLOGYDEV" ]; then
                source /home/vlg/etc/aws/videologydev.cfg
        fi
        export AK="$aws_access_key_id"
        export SAK="$aws_secret_access_key"
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
