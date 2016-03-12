#!/bin/bash
#script is used to calculate the discrepancies in instances spun up by reservations.
#It first Fetched  the reservation and categories it based on availability_region and instance_type and OS.
#From  the same availability_region and instance_type and OS , number of Running instances is derived.
# Unused Reservation is calculated by subtracting the Instances number from reservations number
#
reservation ()
{
ak=$1
sak=$2
acc=$3
aws_region_array=(eu-west-1 sa-east-1 us-east-1 ap-northeast-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2)
echo -ne "Downloading the Reservation and instances information for account $acc"
for region in ${aws_region_array[@]};do
echo -ne "."
ec2-describe-reserved-instances  -O $ak -W $sak -F state=active  --region $region | grep -v RECURRING-CHARGE >> out_$acc
ec2-describe-instances  -O $ak -W $sak -F instance-state-name=running  --region $region | grep -v RECURRING-CHARGE >> ec2_out_$acc
done

cat out_$acc | awk 'OFS="\t"{print $3,$4}'| sort -u  > inst_$acc
echo " "
cat inst_$acc | while read line ;do
type=`echo $line |awk '{print $2}'`
reg=`echo $line  | awk '{print $1}'`
count_res=`cat out_$acc | grep $type | grep $reg | grep -i "windows*" | awk -F "\t" '{sum+=$9}END {print sum}'`

if [ ! -z $count_res ]; then
count_win=`sed 's/\t/|/g' ec2_out_$acc  | grep -w "INSTANCE" | grep $type | grep $reg | grep -w "windows" | wc -l`
if [  -z $count_win ]; then
count_win=0
fi
desc=`echo $count_res - $count_win | bc`

echo -e "$type\t$reg\tWindows\t$count_res\t$count_win\t$desc" >> reservation_rpt_$acc.xls
else
count_res=`cat out_$acc | grep $type | grep $reg | grep -i "Linux*" | awk -F "\t" '{sum+=$9}END {print sum}'`
count_lin=`sed 's/\t/|/g' ec2_out_$acc | grep -w "INSTANCE" | grep $type | grep $reg | awk -F "|" '{if ($15 !="windows") print $0}' | wc -l`
if [  -z $count_lin ]; then
count_lin=0
fi
desc=`echo $count_res - $count_lin | bc`
echo -e "$type\t$reg\tLinux\t$count_res\t$count_lin\t$desc" >> reservation_rpt_$acc.xls
fi
done
cat /dev/null > ec2_out_$acc
cat /dev/null > out_$acc
cat /dev/null > inst_$acc
}

#####################
echo "Please Input the Mail address"
read mail_to
res=`echo ${mail_to} | grep "@"`
if  [ ! -z ${mail_to} ] && [ ${?} == 0 ]  ; then
echo "Email id in proper format"
else
echo "email_id incorrect or not supplied"
fi

from="no.reply@videologygroup.com"
subject="Reservation Report"
body="PFA"

account=(vid lmn)
for acc in ${account[@]};do
if [ $acc == "vid" ];then
key1=AKIAIFVGUARTUV6HPHTQ
key2=2nYqGL7ehSMkugZX3gl/TtMofQ+PzKKHhTE/uynE
reservation $key1 $key2 $acc
else
key1=AKIAJGCNJXKN7NPIQSOQ
key2=n/QbNZpu8kwnP98u8PjYHX8rCEjsDl/BYcPk6Fa5
reservation $key1 $key2 $acc
fi
done
sed -i '1i Instance-Type\tAvailability-Zone\tOS-Platform\tReserved\tRunning\tUnused Reservations' reservation_rpt_vid.xls
sed -i '1i Instance-Type\tAvailability-Zone\tOS-Platform\tReserved\tRunning\tUnused Reservations' reservation_rpt_lmn.xls
echo ${body}| mutt -e "set from=${from}" -s "${subject}" -a reservation_rpt_vid.xls -a  reservation_rpt_lmn.xls -- "${mail_to}"
