#/bin/bash
#INS FILE SORTING
date
echo -e "\t\tVIDEOLOGY!!"
#echo "PLease input the file to operate on"
#read fil
cat > /tmp/ins_opt
if  [ -s "/tmp/ins_opt" ]
then
echo "Retiring Event"
echo "-----------------------------------------------------------------"
echo "Number of RETIRING events is :  `cat "/tmp/ins_opt"   | grep "retiring" | wc -l`"
echo " "
cat "/tmp/ins_opt"   | grep "retiring" | sed  's/\t/\|/g'
echo " "
echo "SCHEDULED REBOOT"
echo "-----------------------------------------------------------------"
echo "Number of Scheduled Reboots are :  `cat "/tmp/ins_opt" | grep reboot| grep EVENT | wc -l`"
echo " "
cat "/tmp/ins_opt" | grep -B4 reboot | grep -v "\"\|SYSTEMSTATUS\|INSTANCESTATUS" | grep -B1 EVENT
#cat 123 | grep reboot| grep EVENT | sed  's/\t/\|/g'
echo " "
echo "ALL other Instances "
echo "Number of INSTANCES are `cat "/tmp/ins_opt" | egrep '^INSTANCE'| wc -l`" : 
cat "/tmp/ins_opt" | egrep '^INSTANCE' | sed  's/\t/\|/g'
else
echo -e "Warning!!!
Either file not present or file is empty
texiting now"
cat /dev/null > /tmp/ins_opt
sleep .25

fi
