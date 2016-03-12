#!/bin/bash

#
# Script for generating a servers list by Platform Tag
#


platforms=( BI Data Eliza Systems Lucy Maya OptDev SQL Layla )
regions=( eu-west-1 sa-east-1 us-east-1 ap-northeast-1 us-west-1 us-west-1 ap-southeast-1 ap-southeast-2 )

for plat in "${platforms[@]}"
do
#  pcount=0
#  prcount=0
  echo -e "\nPlatform: $plat \n" > "$plat"-hosts.txt
  echo -e "==============================\n" >> "$plat"-hosts.txt
  for account in VIDEOLOGY LMN VIDEOLOGYDEV
  do
    if [ "$account" == "VIDEOLOGY" ]
    then
      AK="AKIAIFVGUARTUV6HPHTQ"
      SAK="2nYqGL7ehSMkugZX3gl/TtMofQ+PzKKHhTE/uynE"
    elif [ "$account" == "LMN" ]
    then
      AK="AKIAJGCNJXKN7NPIQSOQ"
      SAK="n/QbNZpu8kwnP98u8PjYHX8rCEjsDl/BYcPk6Fa5"
    elif [ "$account" == "VIDEOLOGYDEV" ]
    then
      AK="AKIAIEGEZTXTZ5HIMCPA"
      SAK="q38ua+3Z5zwERt/AYSsBacFxwuLJhGB2ptr/i6eh"
    fi

    echo -e "\n*** Acount: $account ***\n" >> "$plat"-hosts.txt
    for rgn in ${regions[@]}
    do
      if test `ec2-describe-instances -O $AK -W $SAK --region $rgn -F tag:Platform="$plat"     grep Platform     grep "$plat"     wc -l` -gt 0
      then
        echo -e "\nRegion: $rgn" >> "$plat"-hosts.txt
        echo -e "==============================\n" >> "$plat"-hosts.txt
        ec2-describe-instances -O $AK -W $SAK --region $rgn -F tag:Platform="$plat"     grep "Name"     cut -f'3-5' >> "$plat"-hosts.txt
#        prcount=`ec2-describe-instances -O $AK -W $SAK --region $rgn -F tag:Platform="$plat"     grep Platform     grep "$plat"     wc -l`
#        pcount=$(( pcount + prcount ))          
      fi
    done
  done
  pcount=`cat "$plat"-hosts.txt     grep "Name"     wc -l`
  echo -e "\n\nNumber of "$plat" hosts in total: $pcount" >> "$plat"-hosts.txt
done



