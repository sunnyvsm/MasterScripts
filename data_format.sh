#!/bin/bash
#script to format data
#original format
#new format
echo "Please input the original data file"
read ori_file
echo "Please input the original List_name"
read lst_name
echo "Please input the original doi"
read doi
echo "Please input the starting of uid"
read uid

cat $ori_file | while read line ;do
dob=`echo $line | awk -F "|" '{print $16}' | awk -F "/" '{print $NF}'` 
if [ -z $bod] ; then
year=""
else
year=`date +%Y`
age=`echo $year - $dob | bc`
fi
isp=`echo $line | awk -F "|" '{print $7}'| awk -F "@" '{print $2}'`

case $isp in  
	"hotmail.co.uk")
	 echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> hotmail.co.uk_datafile ;;
	 
	"aol.com")
	 echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> aol.com_datafile ;;
	 
	"gmail.com")
	 echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> gmail.com_datafile ;;
	 
	"googlemail.com")
	 echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> googlemail.com_datafile ;;
	 
	"hotmail.com")
	 echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> hotmail.com_datafile ;;
	 
	"live.com")
	 echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> live.com_datafile ;;
	 
	"live.co.uk")
	 echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> live.co.uk_datafile ;;
	 
	"msn.com")
	 echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> msn.com_datafile ;;
	 
	"outlook.com")
	 echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> outlook.com_datafile ;;
	 
	"rocketmail.com")
	echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> rocketmail.com_datafile ;;
	 
	 "yahoo.com")
	 echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> yahoo.com_datafile ;;
	 
	 "yahoo.co.uk")
	 echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> yahoo.co.uk_datafile ;;
	 
	 "ymail.com")
	 echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> ymail.com_datafile ;;
	 
	 *)
	 echo $line | awk -F "|" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" 'OFS="|"{print uid,$7,lst_name,$2,$3,$5,$6,$8,$9,$(NF-5),$(NF-4),$(NF-3),$(NF-1),age,$NF,"","",doi}' >> other_datafile ;;
	 esac
	 echo -ne "."
uid=$((uid+1))
done	






