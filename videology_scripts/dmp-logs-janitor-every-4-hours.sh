#!/bin/bash

hostname=`hostname`
tomcat="/home/lucidmedia/ClickSense/tomcat/logs"
emailTo="ops@lucidmedia.com"
err=0

for (( i=0;i<2;i++ ))
do
	 date=`date --date="$i day ago" '+%Y-%m-%d'`
	 if [[ i -eq 0 ]];then
		  list="^.*\.${date}.*$"
	 else
		  list="${list}\|^.*\.${date}.*$"
	 sleep 5
	 fi
done


for (( i=0;i<36;i++ ))
do
	 date=`date -d "now - $i hours" '+%Y-%m-%d.%H'`
	 if [[ i -eq 0 ]];then
		  list="${list}\|^.*\.${date}.*$"
	 else
		  list="${list}\|^.*\.${date}.*$"
	 fi

done


if [ -w ${tomcat} ];then
	 pushd ${tomcat} > /dev/null
	 for log in `ls | grep -v "${list}\|catalina.out"`
	 do
		  echo -n "deleting $log: "
		  nice rm -f $log
		  if [ $? -eq 0 ];then
			   echo -en "Ok\n"
		  else
			   echo -en "Error\n"
			   err=1
		  fi
	 done
	 popd > /dev/null
else
	 echo -e "error deleting Tomcat logs. check file permissions and/or disk mount\n"
	 err=1
fi

if [ ${err} -eq 1 ];then
	 mail -s "${hostname}: Logs Janitor Error" ${emailTo} < /home/lucidmedia/Dmp-logs-janitor.txt
fi

