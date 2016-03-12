#!/bin/bash
if [ $# -lt 1 ]
then
echo "You had not supplioed data file. Program exiting Now"
exit
elif [ ! -e $1 ] 
then
echo "File supplied not found, Program exiting Now"
exit
fi
dle=$1
lst_isp=(aol.com gmail.com hotmail.co.uk googlemail.com hotmail.com live.com live.co.uk msn.com outlook.com rocketmail.com yahoo.com yahoo.co.uk ymail.com)
bnc_le='/var/log/pmta/bounce_data'
dte=$(date --date="1 day ago" +"%Y-%m-%d")
file_count=`wc -l $dle | awk '{print $1}'`
#echo $dle
#echo $bnc_le
#echo $dte
for i in ${lst_isp[@]}
do
le_name=$bnc_le/$i"_"bounce"_"$dte
 if [ -e "$le_name" ] ; then
file_count=`wc -l $dle | awk '{print $1}'`
var1=`cat $bnc_le/$i"_"bounce"_"$dte | xargs | sed 's/^/\//' | sed 's/ /\/d;\//g' | sed 's/$/\/d/'`
sed -i $var1 $dle 2> /dev/null
nw_file_count=`wc -l $dle | awk '{print $1}'`
if [ $nw_file_count -lt $file_count ]; then
bounce_clear=`echo $file_count - $nw_file_count | bc`
echo "Total Bounce data for ISP $i leared from file $dle = $bounce_clear"
else
echo "No bounce data for isp $i found in $dle"
fi
fi
done

