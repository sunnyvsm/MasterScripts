#!/bin/bash
#script to monitor the files under /home/crosspixel/ftproot and /home/excelate/ftproot
#email alert is sent to Data Team and GIO if the files are older than 24 hours.
#sh stale_file_check.sh <DP1,DP2,DP3...DPn> all this data providers should have directory structure /home/{dp}/ftproot
ftp_user=$1
IFS=,
lst_usr=($ftp_user)
mail_to="akohale@videologygroup.com"
#mail_to="cybage-systems@videologygroup.com, sanjeev@videologygroup.com, abiy@videologygroup.com, Ron Stiffler ron@videologygroup.com"
mail_from="no.reply@videologygroup.com"
subject1="Different Data-Providers  over `hostname` has files older than 24 hours"
subject2="Different Data-Provider  over `hostname` has 100 and more files older than 24 hours"
flag=0

for users in ${lst_usr[@]} ; do
if [ ! -d /tmp/stale_file_check/DP_24hr_oldfile_check ] ; then
mkdir -p /tmp/stale_file_check/DP_24hr_oldfile_check
fi
all_file_path=/tmp/stale_file_check/DP_24hr_oldfile_check

cd /home/${users}/ftproot &> /dev/null
#cd /home/${users}/app-fte-normalizer &> /dev/null
if [ $? -ne 0 ];then
echo "Home Directory for user ${users} does not exits on  `date`" >> error.txt
continue
fi

count=`find . -maxdepth 1 -type f \( ! -iname ".*" \) -mtime  +1  | wc -l` #this will search for the file older than a day exclusive recursive operation and hidden files.
if [ ${count} -gt 0 ] ; then
pth=${PWD}
echo -e "<td>${pth}</td> <td>${count}</td></tr>" >> ${all_file_path}/output.txt
else
echo "File for user ${users} at location ${pth} not Older than 24hours at time `date`" >> ${all_file_path}/message.txt
fi
if [ ${count} -ge 100 ] ; then
flag=1
fi
done



axis=(ap us uk)
for aw_pth in ${axis[@]}; do
cd /normalizer-output/xaxisturbine/${aw_pth}/xtract &> /dev/null
#cd /home/${users}/app-fte-normalizer &> /dev/null
if [ $? -ne 0 ];then
echo "Home Directory for user xaxisturbine at /normalizer-output/xaxisturbine/${aw_pth}/xtract does not exits on  `date`" >> error.txt
fi
count=`find . -maxdepth 1 -type f \( ! -iname ".*" \) -mtime  +1  | wc -l` #this will search for the file older than a day exclusive recursive operation and hidden files.
if [ ${count} -gt 0 ] ; then
pth=${PWD}
echo -e "<td>${pth}</td> <td>${count}</td></tr>" >> ${all_file_path}/output.txt
else
echo "File for user xaxisturbine at location normalizer-output/xaxisturbine/${aw_pth}/xtract not Older than 24hours at time `date`" >> ${all_file_path}/message.txt
fi
if [ ${count} -ge 100 ] ; then
flag=1
fi
done

lst_usr+=(xaxis)
for i in ${lst_usr[@]}; do
	norm_path=(backup badfiles s3)
	for j in ${norm_path[@]}; do
		cd /normalizer-output/$j/$i &> /dev/null
		if [ $? -ne 0 ];then
			echo "Home Directory for user $i at /normalizer-output/$j/$i does not exits on  `date`" >> error.txt
		fi

		count=`find . -maxdepth 1 -type f \( ! -iname ".*" \) -mtime  +1  | wc -l`
		if [ ${count} -gt 0 ] ; then
		pth=${PWD}
		echo -e "<td>${pth}</td> <td>${count}</td></tr>" >> ${all_file_path}/output.txt
		else
		echo "File for user $i at location /normalizer-output/$j/$i not Older than 24hours at time `date`" >> ${all_file_path}/message.txt
		fi
		if [ ${count} -ge 100 ] ; then
		flag=1
		fi
	done
done	



if [ -s ${all_file_path}/output.txt ]; then  #just for casual check
sed -i '1i <table border="1" style="width:50%"><tr><td><b>FolderName</b></td><td><b>FileCount</b></td></tr><tr>' ${all_file_path}/output.txt
echo -e "</table>" >> ${all_file_path}/output.txt
        echo -e "From:${mail_from}" >> ${all_file_path}/output_1.txt
        echo -e "To:${mail_to}" >> ${all_file_path}/output_1.txt
        #echo -e "To:${mail_to}" >> ${all_file_path}/output_1.txt
        echo -e "Content-Type: text/html" >> ${all_file_path}/output_1.txt
        cp ${all_file_path}/output_1.txt ${all_file_path}/output_2.txt
        echo -e "Subject: ${subject2}" >> ${all_file_path}/output_2.txt
        echo -e "Subject: ${subject1}" >> ${all_file_path}/output_1.txt

  cat ${all_file_path}/output.txt >> ${all_file_path}/output_2.txt
  cat ${all_file_path}/output.txt >> ${all_file_path}/output_1.txt
  /usr/sbin/sendmail -t < ${all_file_path}/output_1.txt
fi

if [ ${flag} -eq 1 ] ; then
/usr/sbin/sendmail -t < ${all_file_path}/output_2.txt
fi

cat /dev/null > ${all_file_path}/output_1.txt
cat /dev/null > ${all_file_path}/output.txt
cat /dev/null > ${all_file_path}/output_2.txt
