
#!/bin/bash/
aws_region_array=(eu-west-1 sa-east-1 us-east-1 ap-northeast-1 us-west-1 us-west-2 ap-southeast-1 ap-southeast-2)
ami_id=(ami-9447c3fc ami-44bf502c ami-600a6108)
echo "Downloading the instances information"
for rgn in ${aws_region_array[@]}; do
echo -ne ".."
for ids in ${ami_id[@]}; do 
ec2-describe-instances --filter image-id="${ids}" -O AKIAIFVGUARTUV6HPHTQ -W 2nYqGL7ehSMkugZX3gl/TtMofQ+PzKKHhTE/uynE --region ${rgn} >> /tmp/output
done
done
#exit
cat /tmp/output  | grep -w "INSTANCE" | while read line ; do
ins=`echo $line | awk '{print $2}'`
Name=`cat /tmp/output | grep ${ins}|grep TAG  |grep -w "Name" | awk '{for (i=5; i<=NF; i++) {printf "%s",$i} printf "\n"}'`
Platform=`cat /tmp/output | grep ${ins}|grep TAG  |grep -w "Platform" | awk '{for (i=5; i<=NF; i++) {printf "%s",$i} printf "\n"}'`
Environment=`cat /tmp/output | grep ${ins}|grep TAG  |grep -w "Environment" | awk '{for (i=5; i<=NF; i++) {printf "%s",$i} printf "\n"}'`
Owner=`cat /tmp/output | grep ${ins}|grep TAG  |grep -w "Owner" | awk '{for (i=5; i<=NF; i++) {printf "%s",$i} printf "\n"}'`
Application=`cat /tmp/output | grep ${ins}|grep TAG  |grep -w "Application" | awk '{for (i=5; i<=NF; i++) {printf "%s",$i} printf "\n"}'`
#echo -e "${Platform}\n${Environment}\n${Owner}\n${Application}\n${Name}"
#exit
if [ "${Name}" == "TeamCityAgent" ] && [ "${Platform}" == "MIS" ] && [ "${Environment}" == "Sandbox" ] && [  "${Owner}" == "Maya" ] && [ "${Application}" == "Teamcity" ] ; then echo -e "\nTagging information for instance ${ins} is correct , moving to next instance" ;continue ; else
echo -e "\nCorrecting the Tagging information for instance ${ins}"
ec2-create-tags ${ins} -O AKIAIFVGUARTUV6HPHTQ -W 2nYqGL7ehSMkugZX3gl/TtMofQ+PzKKHhTE/uynE --tag "Name=TeamCity Agent" --tag "Platform=MIS" --tag "Environment=Sandbox" --tag "Owner=Maya" --tag "Application=Teamcity" ; fi
done
echo "All Insatnces had been tagged properly. :)"
cat /dev/null > /tmp/output
