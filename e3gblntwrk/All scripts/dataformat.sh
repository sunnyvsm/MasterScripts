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
echo "Please input the country code"
read ccode

dd=`date +%y-%m-%d`
cat $ori_file | while read line ;do
yob=`echo $line | awk -F "," '{print $15}' | awk -F "/" '{print $3}'`
#pid=`echo $line | awk -F "," '{print $2}'`
#if [ -z "$yob" ] ;
#then
#year=""
#age=""
#else
#year=`date +%Y`
#age=`echo $year - $yob | bc`
#fi
base_dir="/root/database/all_data"
age=""
clicks=""
imp=""
isp=`echo $line | awk -F "," '{print $6}'| awk -F "@" '{print $2}'`
pid=`echo $line | awk -F "," '{print $2}'`

case $isp in
        "hotmail.co.uk")
         echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/hotmail/${pid}_uk_$dd ;;

        "aol.com")
         echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/aol/${pid}_us_$dd ;;

        "gmail.com")
         echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/gmail/${pid}_us_$dd ;;

        "googlemail.com")
         echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/gmail/${pid}_us_$dd ;;

        "hotmail.com")
         echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/hotmail/${pid}_us_$dd ;;

        "live.com")
         echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/hotmail/${pid}_us_$dd ;;

        "live.co.uk")
         echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/hotmail/${pid}_uk_$dd ;;

        "msn.com")
         echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/hotmail/${pid}_us_$dd ;;

        "outlook.com")
         echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/hotmail/${pid}_us_$dd ;;

        "rocketmail.com")
        echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/yahoo/${pid}_us_$dd ;;

         "yahoo.com")
         echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/yahoo/${pid}_us_$dd ;;

         "yahoo.co.uk")
         echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/yahoo/${pid}_uk_$dd ;;

         "ymail.com")
         echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/yahoo/${pid}_us_$dd ;;

         *)
         echo $line | awk -F "," -v clicks="$clicks" -v imp="$imp" -v uid="$uid" -v lst_name="$lst_name" -v doi="$doi" -v age="$age" -v ccode="$ccode" 'OFS="|"{print uid,$6,lst_name,$2,$3,$4,$5,$7,$8,$12,$13,$14,$15,age,$16,clicks,imp,doi,ccode}' >> ${base_dir}/other/${pid}_$dd ;;
         esac
         echo -ne "."
uid=$((uid+1))
done
