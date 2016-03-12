#!/bin/bash

echo "Enter the region (usva, euir , apac , usor )"
read region
echo "Enter what Year (2014 2015 ..)"
read year
echo "Enter the Month (01 02 .. 12)"
read month
echo "Enter what day"
read day
echo "Enter Placement ID (103214 108653 109429 ..)"
read id
echo "Number of line you want to print from the s3 log?"
read logct
echo "Please provide the path where to download the files? (/tmp or /testarea)"
read logPath

check (){
  line_count=$(cat ${logPath}/${id}_ClickStream_log_Count.txt | wc -l)
  if [ "${line_count}" -ge "${logct}" ]; then
    break
  fi
}

for i in $(seq 0 23); do
  if (( "$i" < "10" )); then
    i=0$i
  fi
  mkdir -p ${logPath}/ClickStream/$region/$year/$month/$day/$i
  cd ${logPath}/ClickStream/$region/$year/$month/$day/$i
  case "$region" in
    usva)
      s3cmd get --skip-existing s3://ttv-logs/tsv/clickstream/y=$year/m=$month/d=$day/h=$i/$year*
	  zcat "${year}"* | awk -F $'\t' '$11 ~ /^'${id}'/ {print}' >> /testarea/scripts/${id}_ClickStream_log_Count.txt
      ;;
    euir)
      s3cmd get --skip-existing s3://vg-eu-west-1-logs/tsv/clickstream/y=$year/m=$month/d=$day/h=$i/$year*
      zcat "${year}"* | awk -F $'\t' '$11 ~ /^'${id}'/ {print}' >> ${logPath}/${id}_ClickStream_log_Count.txt
      ;;
    apac)
      s3cmd get --skip-existing s3://vg-singapore-logs/tsv/clickstream/y=$year/m=$month/d=$day/$year*
	  zcat "${year}"* | awk -F $'\t' '$11 ~ /^'${id}'/ {print}' >> ${logPath}/${id}_ClickStream_log_Count.txt
      ;;
    *)
      echo "Dont you understand, pick one region usva,euir,apac,usor"
  esac
  check
  rm -rf ${logPath}/ClickStream/$region/$year/$month/$day/$i
done

echo -e "Please download the file ${logPath}/${id}_ClickStream_log_Count.txt"