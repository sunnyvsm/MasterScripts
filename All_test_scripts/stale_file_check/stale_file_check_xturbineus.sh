#!/bin/bash
#script to monitor the files under /home/crosspixel/ftproot and /home/excelate/ftproot
#email alert is sent to Data Team and GIO if the files are older than 24 hours.
#sh stale_file_check.sh <ftp user>
ftp_user=$1
mail_to_1="Systems.Contractors@videologygroup.com"
#mail_to_1="akohale@videologygroup.com"
mail_to_2="DBA_Support@videologygroup.com"
mail_from="no.reply@videologygroup.com"
subject="Data-Provider ${ftp_user} over `hostname` has files older than 24 hours"
subject2="Data-Provider ${ftp_user} over `hostname` has 100 and more files older than 24 hours"
flag=0
if [ ! -d /stale_file_check/DP_24hr_oldfile_check ] ; then
mkdir /stale_file_check/DP_24hr_oldfile_check
fi
all_file_path=/stale_file_check/DP_24hr_oldfile_check


cd /normalizer-output/xaxisturbine/us/xtract &> /dev/null
if [ $? -ne 0 ];then
echo "Directory /normalizer-output/xaxisturbine/us/xtract/ for user xaxisturbine does not exits at `date`" >> error.txt
else
count=`find . -type f  -name ="turbine.*" -mtime  +1  | wc -l`
        if [ ${count} -gt 0 ] ; then
                pth=${PWD}
        echo -e "<td>${pth}</td> <td>${count}</td></tr></table>" >> ${all_file_path}/output.txt
        else
        echo "File for user xaxisturbine at location /xaxisturbine/us/xtract/ not Older than 24hours at time `date`" >> ${all_file_path}/message.txt
        fi
fi
if [ ${count} -ge 100 ] ; then
flag=1
fi


if [ -s ${all_file_path}/output.txt ]; then  #just for casual check
sed -i '1i <table border="1" style="width:50%"><tr><td><b>FolderName</b></td><td><b>FileCount</b></td></tr><tr>' ${all_file_path}/output.txt
echo -e "From:${mail_from}" >> ${all_file_path}/output_1.txt
  echo -e "To:${mail_to_1}" >> ${all_file_path}/output_1.txt
  #echo -e "To:${mail_to_2}" >> ${all_file_path}/output_1.txt
  echo -e "Content-Type: text/html" >> ${all_file_path}/output_1.txt
  cp ${all_file_path}/output_1.txt ${all_file_path}/output_2.txt
  echo -e "Subject: ${subject2}" >> ${all_file_path}/output_2.txt
  echo -e "Subject: ${subject}" >> ${all_file_path}/output_1.txt

  cat ${all_file_path}/output.txt >> ${all_file_path}/output_2.txt
  cat ${all_file_path}/output.txt >> ${all_file_path}/output_1.txt
  /usr/sbin/sendmail -t < ${all_file_path}/output_1.txt
fi

if [ ${flag} -eq 1 ] ; then
/usr/sbin/sendmail -t < ${all_file_path}/output_2.txt
fi

cat /dev/null > ${all_file_path}/output_1.txt
cat /dev/null > ${all_file_path}/output.txt