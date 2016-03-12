#!/bin/bash
#script to monitor the files under /home/crosspixel/ftproot and /home/excelate/ftproot
#email alert is sent to Data Team and GIO if the files are older than 24 hours.

users=(CrossPixel excelate)
mail_to="Systems.Contractors@videologygroup.com"
flag=0
for usr in ${users[@]}; do
cd /home/${usr}/ftproot &> /dev/null
if [ $? != 0 ] ; then
echo "Home Directory for user ${usr} is not set properly,Please Check" | mail -s "Data-Provider ${usr} Home-Dir Error " ${mail_to}
echo "Home directory for ${usr} does not exists, Mail sent at `date`" >> /tmp/DP_24hr_oldfilecheck_log
#flag=1
continue
fi
#find . -maxdepth 1 -type f -mtime  +1  | wc -l 
#find . -type f \( -iname "*.txt" ! -iname ".*" \)
pth=${PWD}
count=`find . -type f \( ! -iname ".bash*" \) -mtime  +1  | wc -l`
if [ ${count} -gt 0 ] ; then 
echo -e "<td>${pth}</td> <td>${count}</td></tr></table>" >> /tmp/DP_24hr_oldfile_count
else 
echo "File for user ${usr} not Older than 24hours at time `date`" >> /tmp/DP_24hr_oldfilecheck_log
fi
done
if [ -s /tmp/DP_oldfile_old_count ]; then  #just for casual check
sed -i '1i <table border="1" style="width:50%"><tr><td><b>FolderName</b></td><td><b>FileCount</b></td></tr><tr>' /tmp/DP_24hr_oldfile_count
mail -s "$(echo -e "One or more Data-Providers over usvaftpprd08 has files older than 24 hours\nContent-Type: text/html")" ${mail_to} < /tmp/DP_24hr_oldfile_count
fi
cat /dev/null > /tmp/DP_24hr_oldfile_count
echo "----------------" >> /tmp/DP_24hr_oldfilecheck_log
#completed 
