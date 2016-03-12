#!/bin/bash

#email alert is sent to cybage-systems@videologygroup.com, sanjeev@videologygroup.com, abiy@videologygroup.com, ron@videologygroup.com and GIO if the files are older than 24 hours.
#sh stale_file_check.sh <DP1,DP2,DP3...DPn> all this are data providers.
#ftp_user=$1
sftp_usr=$(cat /etc/group  | grep ftp | awk -F ':' '{print $4}' | sed -E  's/(.*)\,(geyser_stag)(.*)$/\1\3/')
IFS=,
lst_usr=($sftp_usr)

mail_to="cybage-systems@videologygroup.com, sanjeev@videologygroup.com, abiy@videologygroup.com, ron@videologygroup.com"
mail_from="no.reply@videologygroup.com"
subject1="Different Data-Providers  over `hostname` has files older than 24 hours"
subject2="Different Data-Provider  over `hostname` has 100 and more files older than 24 hours"
flag=0
axis=(ap us uk)
if [ ! -d /tmp/stale_file_check/DP_24hr_oldfile_check ] ; then
	mkdir -p /tmp/stale_file_check/DP_24hr_oldfile_check
fi
for users in ${lst_usr[@]} ; do
	 all_file_path=/tmp/stale_file_check/DP_24hr_oldfile_check
	 cd /home/${users}/ftproot &> /dev/null
	if [ $? -ne 0 ];then
		echo "Home Directory for user ${users} does not exits on  `date`" >> ${all_file_path}/error.txt
	else
		count=`find . -maxdepth 1 -type f \( ! -iname ".*" \) -mtime  +1  | wc -l` #this will search for the file older than a day exclusive recursive operation and hidden files.
			if [ ${count} -gt 0 ] ; then
				pth=${PWD}
				echo -e "<td>${pth}</td> <td>${count}</td></tr>" >> ${all_file_path}/output.txt
			else
				echo "File for user ${users} at location ${pth} not Older than 24hours at time `date`" >> ${all_file_path}/message.txt
			fi
	fi 

        #if [ ${count} -ge 100 ] ; then
        #        flag=1
        #fi
done

for aw_pth in ${axis[@]}; do
	cd /normalizer-output/xaxisturbine/${aw_pth}/xtract &> /dev/null
    #cd /home/${users}/app-fte-normalizer &> /dev/null
		if [ $? -ne 0 ];then
			echo "Home Directory for user xaxisturbine at /normalizer-output/xaxisturbine/${aw_pth}/xtract does not exits on  `date`" >> ${all_file_path}/error.txt
        else
			count=`find . -maxdepth 1 -type f \( ! -iname ".*" \) -mtime  +1  | wc -l` #this will search for the file older than a day exclusive recursive operation and hidden files.
				if [ ${count} -gt 0 ] ; then
					pth=${PWD}
					echo -e "<td>${pth}</td> <td>${count}</td></tr>" >> ${all_file_path}/output.txt
				else
					echo "File for user xaxisturbine at location normalizer-output/xaxisturbine/${aw_pth}/xtract not Older than 24hours at time `date`" >> ${all_file_path}/message.txt
				fi
		fi	
       # if [ ${count} -ge 100 ] ; then
       #         flag=1
       # fi
done

lst_usr+=(xaxis)

for i in ${lst_usr[@]}; do
	norm_path=(backup badfiles s3)
	for j in ${norm_path[@]}; do
		cd /normalizer-output/$j/$i &> /dev/null
		if [ $? -ne 0 ];then
			echo "Home Directory for user $i at /normalizer-output/$j/$i does not exits on  `date`" >> ${all_file_path}/error.txt
		else

            count=`find . -maxdepth 1 -type f \( ! -iname ".*" \) -mtime  +1  | wc -l`
			if [ ${count} -gt 0 ] ; then
				pth=${PWD}
                echo -e "<td>${pth}</td> <td>${count}</td></tr>" >> ${all_file_path}/output.txt
			else
                echo "File for user $i at location /normalizer-output/$j/$i not Older than 24hours at time `date`" >> ${all_file_path}/message.txt
            fi
		fi	
                #if [ ${count} -ge 100 ] ; then
                #        flag=1
                #fi
    done
done

if [ -s ${all_file_path}/output.txt ]; then  #just for casual check
	sed -i '1i <table border="1" style="width:50%"><tr><td><b>FolderName</b></td><td><b>FileCount</b></td></tr><tr>' ${all_file_path}/output.txt
    echo -e "</table>" >> ${all_file_path}/output.txt
    echo -e "From:${mail_from}" >> ${all_file_path}/output_1.txt
    echo -e "To:${mail_to}" >> ${all_file_path}/output_1.txt
    echo -e "Content-Type: text/html" >> ${all_file_path}/output_1.txt
    #cp ${all_file_path}/output_1.txt ${all_file_path}/output_2.txt
    #echo -e "Subject: ${subject2}" >> ${all_file_path}/output_2.txt
    echo -e "Subject: ${subject1}" >> ${all_file_path}/output_1.txt
    #cat ${all_file_path}/output.txt >> ${all_file_path}/output_2.txt
    cat ${all_file_path}/output.txt >> ${all_file_path}/output_1.txt
    /usr/sbin/sendmail -t < ${all_file_path}/output_1.txt
fi

#if [ ${flag} -eq 1 ] ; then
#        /usr/sbin/sendmail -t < ${all_file_path}/output_2.txt
#fi

cat /dev/null > ${all_file_path}/output_1.txt
cat /dev/null > ${all_file_path}/output.txt
cat /dev/null > ${all_file_path}/output_2.txt[