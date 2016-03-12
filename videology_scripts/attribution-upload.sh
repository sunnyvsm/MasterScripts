#!/bin/bash

hostname=`hostname`
shutdown=$1
emailTo="systems@videologygroup.com"
logDir="/mnt/lucidmedia/ClickSense/local/logs/"
archiveDir="/archive/logs"
permissions="read:f94517569a30d3fcf916070bbdbb18364d6705c127b7eac7858ac22418db16c8"
fileList="data-attribution*"
retry=6
count=0
err=0
success=0
bucket

region=`echo ${hostname} | sed -e 's/^...\(.\)..[0-9][0-9]$/\1/g'`
if [ "${region}" = "e" ] || [ `echo ${hostname} | grep -c "usva"` -eq 1  ];then
        prefix="usva"
elif [ `echo ${hostname} | grep -c "usor"` -eq 1  ];then
        prefix="usor"
elif [ `echo ${hostname} | grep -c "usca"` -eq 1  ];then
        prefix="usca"
elif [ "${region}" = "u" ] || [ `echo ${hostname} | grep -c "euir"` -eq 1  ];then
        prefix="euir"
elif [ "${region}" = "a" ] || [ `echo ${hostname} | grep -c "apsg"` -eq 1  ];then
        prefix="apsg"
else
        echo "ERROR: invalid region in hostname: ${hostname}"
        exit 1
fi

if [ -d ${logDir} ];then
        pushd ${logDir} > /dev/null
        for file in ${fileList}
        do
                if [ `echo "${file}" | grep -E -c  "^${file}.{1,}[0-9]{2}-[0-9]{2}-[0-9]{2}$"` -eq 1 ];then
                        bucket="${prefix}lzlogs/datacosts/in"
                fi
bucket="${prefix}lzlogs/datacosts/in"

                _count=`ls | grep -E "^${file}.{1,}[0-9]{2}-[0-9]{2}-[0-9]{2}$" | wc -l`
                count=$(($count + $_count))
                echo $count

                for log in `ls | grep -E "^${file}.{1,}[0-9]{2}-[0-9]{2}-[0-9]{2}$"`
                do
                        if [ `echo ${log} | grep -E -c "^${file}"` -eq 1 ];then
                                date=`echo ${log} | sed -e 's/^.*\.\([0-9]\+\)-\([0-9]\+\)-\([0-9]\+\).*$/\1-\2-\3/g'`
                                hour=`echo ${log} | sed -e 's/^.*\.\([0-9]\+\)-\([0-9]\+\)-\([0-9]\+\)-\([0-9]\+\).*$/\4/g'`
                                destFile=${log}.${hostname}
                        elif [ "${shutdown}" = "yes" ] && [ `echo ${log} | egrep -c "^${file}\.log$"` -eq 1 ];then
                                date=$(date --date="`stat -c %y ${log} | awk '{print $1}'`" +"%y-%m-%d")
                                hour=$(stat -c %y ${log} | awk '{print $2}' | awk -F ':' '{print $1}')
                                destFile=${log}.${date}-${hour}.${hostname}
                                count=$(($count+1))
                        else
                                continue
                        fi

                        echo -n "Uploading $log to s3://${bucket}/${date}/${hour}/${destFile}: "
                        if [ `s3cmd ls s3://${bucket}/${date}/${hour}/ 2>/dev/null | grep -c -w "\${destFile}$"` -eq 1 ];then
                                epoch=`date +%s`
                                destFile=${destFile}.${epoch}
                                echo -en "Already EXISTS.\nUploading ${destFile}: "
                        fi

                        while [ $retry -gt 0 ];
                        do
                                s3cmd --multipart-chunk-size-mb=512 put ${log} s3://${bucket}/${date}/${hour}/${destFile} 1>/dev/null 2>&1
                                if [ "`s3cmd ls s3://${bucket}/${date}/${hour}/${destFile} 2>/dev/null | awk '{print $3}'`" = "`du -sb ${log} 2>/dev/null | awk '{print $1}'`" ];then
                                        echo -en "ok\n"
                                        echo -n "Deleting the logs: "
                                        rm -f ${log}
                                        if [ $? -eq 0 ];then
                                                let success=${success}+1
                                                s3cmd setacl --acl-grant=${permissions} s3://${bucket}/${date}/${hour}/${destFile}
                                                echo -en "ok\n"
                                        else
                                                echo -en "error\n"
                                        fi
                                        echo -e "\r"
                                        break
                                else
                                        echo -en "error\n"
                                fi
                                let retry=${retry}-1
                                echo -e "\r"
                                echo "Retrying in 1 min...: ${retry}"
                                sleep 60
                        done
                        if [ $retry -eq 0 ];then
                                echo -e "\r"
                                echo "Retries failed"
                                err=1
                        fi
                done
        done
        popd > /dev/null
else
        echo -e "${logDir} doesn't exist"
fi

echo "Processed $success of $count file(s)"

if [ $count -ne $success ];then
        err=1
fi

if [ ${err} -eq 1 ];then
        mail -s "${hostname}: ${fileList} logs S3 Upload Error" ${emailTo} < /home/lucidmedia/${fileList}-upload.txt
        exit 1
fi
