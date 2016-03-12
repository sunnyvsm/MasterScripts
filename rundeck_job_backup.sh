#!/bin/bash
#export the jobs
export EC2_HOME=/usr/local/share/ec2_tools
export JAVA_HOME=/usr/lib/jvm/java
export PATH=$EC2_HOME/bin:$JAVA_HOME/bin:$PATH
source /home/vlg/etc/aws/videology.cfg
export AK="$aws_access_key_id"
export SAK="$aws_secret_access_key"
s3_location='s3://videologypublic/test/'
EMAIL_FROM="no.reply@videologygroup.com"
SUBJECT="Rundeck Jobs Backup Failed"
#EMAIL_ID="cybage-systems@videologygroup.com"
EMAIL_ID="akohale.consultant@videologygroup.com"


jobs_backup_location='/tmp/rundeck_backup/Jobs'
data_backup_location='/tmp/rundeck_backup/Data'
log_backup_location='/tmp/rundeck_backup/Log'
array_1=(Jobs Data Log)
array_2=(AppDev Chef Data GIO Lucy OptDev vAds)

for i in ${array_1[@]}; do
if [ ! -d /tmp/rundeck_backup/$i ]; then
mkdir -p /tmp/rundeck_backup/$i
fi
done

bck_status()
{
if [ "$1" == 0 ]
then
echo "File ${j}.xml was backed up successfuly at s3 location s3://vg-gio/rundeck/rundeck_backup/Jobs/" 
else
echo -e "File ${j}.xml was not backed up successfuly at s3 location.\n" | tee  /tmp/rundeck_backup/rdkupld_error
fi
}
 
for j in ${array_2[@]}; do
/usr/bin/rd-jobs list -f ${jobs_backup_location}/${j}.xml -p $j &> /dev/null
if [ -s "${jobs_backup_location}/${j}.xml" ] ; then
s3cmd sync ${jobs_backup_location}/${j}.xml s3://vg-gio/rundeck/rundeck_backup/Jobs/ --recursive --access_key=${AK} --secret_key=${SAK}
stat=$?
bck_status $stat
else
bck_status 1
fi
done

if [ -e /tmp/rundeck_backup/rdkupld_error ]; then
echo -e "From:$EMAIL_FROM" >> /tmp/vtem.txt
echo -e "To:$EMAIL_ID" >> /tmp/vtem.txt
echo -e "Subject: $SUBJECT" >> /tmp/vtem.txt
echo -e "Content-Type: text/plain" >> /tmp/vtem.txt
echo -e "Backing of Rundeck Jobs was Failed below is its details:\n" >> /tmp/vtem.txt
cat /tmp/rundeck_backup/rdkupld_error  >> /tmp/vtem.txt
/usr/sbin/sendmail -t < /tmp/vtem.txt
fi
cat /dev/null > /tmp/vtem.txt
cat /dev/null > /tmp/rundeck_backup/rdkupld_error
rm -rf /tmp/rundeck_backup

 
 
