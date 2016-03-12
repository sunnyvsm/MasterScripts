#!/bin/bash

#
# Script for listing and optionally tagging untagged volumes
#

# EC2_HOME variable value to be set based on the installation location of EC2 tools on the host
export EC2_HOME=/usr/local/share/ec2_tools
export JAVA_HOME=/usr/lib/jvm/java
export PATH=$EC2_HOME/bin:$JAVA_HOME/bin:$PATH
export JAVA_OPTIONS='-Xms64M -Xmx128m'
aws_account_array=()
aws_region_array=()
ak_array=()
sak_array=()
AK=""
SAK=""
emponlyFlag=""
EMAIL_FROM="no.reply@videologygroup.com"
SUBJECT="Improperly Tagged Volumes"
TFDIR="./TFD"

function parse_arguments()
{
  while [ ! -z $1 ]
  do
    param=`echo $1 | awk -F= '{ print $1 }'`
    value=`echo $1 | awk -F= '{print $2}'`

    case $param in
      --help|-h)
        usage
        exit 1
        ;;
      --email_id|-e)
        EMAIL_ID=$value
        ;;
      --aws_account)
        local items=$value
        if [ "$items" == "All" ] || [ "$items" == "ALL" ] || [ "$items" == "all" ]; then
          aws_account_array=(VIDEOLOGY VIDEOLOGYDEV LMN)
        else
          for awsacc_element in `echo -e $items | tr , '\n'`
          do
            aws_account_array=("${aws_account_array[@]}" "$awsacc_element")
          done
        fi
        ;;
      --ak)
        local items=$value
        for ak_element in `echo -e ${items} | tr , '\n'`
        do
          ak_array=("${ak_array[@]}" "$ak_element")
        done
        ;;
      --sak)
        local items=$value
        for sak_element in `echo -e ${items} | tr , '\n'`
        do
          sak_array=("${sak_array[@]}" "$sak_element")
        done
        ;;
      --region)
        local items=$value
        if [ "$items" == "All" ] || [ "$items" == "ALL" ] || [ "$items" == "all" ]; then
          aws_region_array=(us-east-1 us-west-2 eu-west-1 ap-northeast-1 ap-southeast-1)
        else
          for rgn_element in `echo -e ${items} | tr , '\n'`
          do
            aws_region_array=("${aws_region_array[@]}" "$rgn_element")
          done
        fi
        ;;
      --default-keys)
        ak_array=("AKIAIFVGUARTUV6HPHTQ" "AKIAIEGEZTXTZ5HIMCPA" "AKIAJGCNJXKN7NPIQSOQ")
        sak_array=("2nYqGL7ehSMkugZX3gl/TtMofQ+PzKKHhTE/uynE" "q38ua+3Z5zwERt/AYSsBacFxwuLJhGB2ptr/i6eh" "n/QbNZpu8kwnP98u8PjYHX8rCEjsDl/BYcPk6Fa5")
        if [ ${aws_account_array[0]} != "VIDEOLOGY" ] || [ ${aws_account_array[1]} != "VIDEOLOGYDEV" ] || [ ${aws_account_array[2]} != "LMN" ]
        then
          echo -e "Error: "
          echo "When using --default-keys, the sequence of specifying AWS accounts should always be \"VIDEOLOGY,VIDEOLOGYDEV,LMN\" "
          exit 1
        fi
        ;;
      --default-args)
        aws_account_array=(VIDEOLOGY VIDEOLOGYDEV LMN)
        aws_region_array=(us-east-1 us-west-2 eu-west-1 ap-northeast-1 ap-southeast-1)  
        ak_array=("AKIAIFVGUARTUV6HPHTQ" "AKIAIEGEZTXTZ5HIMCPA" "AKIAJGCNJXKN7NPIQSOQ")
        sak_array=("2nYqGL7ehSMkugZX3gl/TtMofQ+PzKKHhTE/uynE" "q38ua+3Z5zwERt/AYSsBacFxwuLJhGB2ptr/i6eh" "n/QbNZpu8kwnP98u8PjYHX8rCEjsDl/BYcPk6Fa5")
        ;;
      --empty-tags-only)
        emponlyFlag="1"
        ;;
      --report-only)
        rponlyFlag="1"
	;;
    esac
    shift
  done
}

function parse_keys()
{
  # Find the index_num of $account in aws_account_array. Use ak_array[index_num] and sak_array[index_num] 
  # as the access_key and security_access_key respectively for the account
  
  local acct="$1"
  
  if [ "$acct" == "VIDEOLOGY" ]
  then
    source /home/vlg/etc/aws/videology.cfg
  elif [ "$acct" == "LMN" ]
  then
    source /home/vlg/etc/aws/lmn.cfg
  elif [ "$acct" == "VIDEOLOGYDEV" ]
  then
    source /home/vlg/etc/aws/videologydev.cfg
  fi
  export AK="$aws_access_key_id"
  export SAK="$aws_secret_access_key"
}
function usage()
{
  echo "
  Usage:
  vol_tag_all [OPTIONS]
      --email_id	Required. Value: [Email_Id_Of_The_Contact_To_Be_Alerted_About_Volume_Tagging_Updates]
      --aws_account	Required. Value: Comma-separated list of AWS accounts - All|VIDEOLOGY|VIDEOLOGYDEV|LMN
      --akey		Comma-separated list of Access Keys for each AWS account specified in the sequence in which AWS accounts have been specified
      --sakey		Comma-separated list of Secret Access Keys for each AWS account specified in the sequence in which AWS accounts have been specified
      --region		Comma-separated list of regions to be checked for volume tags from either or all of 
                        us-east-1,us-west-2,eu-west-1,ap-northeast-1,ap-southeast-1 
      --default-keys    A default set of Access Keys and Secret Access Keys will be used rather than user-specified keys
      --default-args    No arguments need to be provided to the script other than --email-id. The script will use the default set of Keys, Account Names,                            Regions etc
      --empty-tags-only Only updates those volume tags which are empty and inconsistent
      --report-only     Only reports the inconsistencies in volume tags via email, but doesn't correct them
  Example:
  $ sudo vol_tag_all.sh --email_id=\"yhasabnis@videologygroup.com\" --aws_account=\"LMN,VIDEOLOGYDEV\" --ak=\"AKey for LMN\",\"AKey for VIDEOLOGYDEV\" --sak=\"SAKey for LMN\",\"SAKey for VDIEOLOGYDEV\" --region=\"ap-southeast-1,us-east-1\" 

  "                 
}


if [ $# -gt 0 ]
then
  parse_arguments $@
else
  parse_arguments --help
fi

ACCT_COUNT=${#aws_account_array[@]}
NO_DISC_COUNT=0

if [ "${#aws_account_array[@]}" -ne "${#ak_array[@]}" ] || [ "${#aws_account_array[@]}" -ne "${#sak_array[@]}" ]; then
  echo -e "The count of AWS accounts is not equal to that of access_keys/security_access_keys"
  exit 1
fi

rm -rf ./$TFDIR/* && mkdir -p $TFDIR

for account in ${aws_account_array[@]}
do
    parse_keys $account
    echo -e "\n*** Account: $account ***\n" >> "$TFDIR"/"$account"-inconsistent.txt
    echo -e "=========================================================================\n" >> "$TFDIR"/"$account"-inconsistent.txt

    for rgn in ${aws_region_array[@]}
    do
      rm -f "$TFDIR"/"$account"-"$rgn"-attached.txt
      touch "$TFDIR"/"$account"-"$rgn"-attached.txt
      touch "$TFDIR"/"$account"-"$rgn"-inconsistent.txt
      touch "$TFDIR"/"$account"-"$rgn"-inconsistent_tmp.txt
    
      ec2-describe-volumes -O $AK -W $SAK --region $rgn --filter attachment.status="attached" | grep "ATTACHMENT" | awk '{ print $2," ",$3 }' >> "$TFDIR"/"$account"-"$rgn"-attached.txt
      cat "$TFDIR"/"$account"-"$rgn"-attached.txt | while read in;
      do
        Inst_Id=`echo $in | awk '{ print $2 }'`
        Vol_Id=`echo $in | awk '{ print $1 }'`
        echo -e "\n$Inst_Id" >> "$TFDIR"/"$account"-"$rgn"-tags.txt
        echo -e "$Vol_Id" >> "$TFDIR"/"$account"-"$rgn"-tags.txt
        iTagPlat=`ec2-describe-tags -O $AK -W $SAK --region $rgn -F resource-id="$Inst_Id" -F key="Platform" | awk -F'\t' '{ print $5 }'`
        vTagPlat=`ec2-describe-tags -O $AK -W $SAK --region $rgn -F resource-id="$Vol_Id" -F key="Platform" | awk -F'\t' '{ print $5 }'`
        iTagEnv=`ec2-describe-tags -O $AK -W $SAK --region $rgn -F resource-id="$Inst_Id" -F key="Environment" | awk -F'\t' '{ print $5 }'`
        vTagEnv=`ec2-describe-tags -O $AK -W $SAK --region $rgn -F resource-id="$Vol_Id" -F key="Environment" | awk -F'\t' '{ print $5 }'`
        iTagApp=`ec2-describe-tags -O $AK -W $SAK --region $rgn -F resource-id="$Inst_Id" -F key="Application" | awk -F'\t' '{ print $5 }'`
        vTagApp=`ec2-describe-tags -O $AK -W $SAK --region $rgn -F resource-id="$Vol_Id" -F key="Application" | awk -F'\t' '{ print $5 }'`

        if [ "$emponlyFlag" == "1" ]
        then
        # Only update empty volume tags
          if [ "$iTagPlat" != "$vTagPlat" ] && [ -z "$vTagPlat" ]
          then
            echo -e "Tagging Inconsistency for Instance $Inst_Id and Volume $Vol_Id in region $rgn" >> "$TFDIR"/"$account"-inconsistent_tmp.txt
            echo -e "Instance_Platform_Tag: $iTagPlat vs Volume_Platform_Tag: $vTagPlat" >> "$TFDIR"/"$account"-inconsistent_tmp.txt
            if [ "$rponlyFlag" != "1" ]; then
              ec2-create-tags -O $AK -W $SAK --region $rgn "$Vol_Id" --tag "Platform=$iTagPlat"
              echo -e "\nUpdated Platform tag for Volume $Vol_Id to $iTagPlat \n" >> "$TFDIR"/"$account"-inconsistent_tmp.txt 
	    fi  
          fi
          if [ "$iTagEnv" != "$vTagEnv" ] && [ -z "$vTagEnv" ]
          then
            echo -e "Tagging Inconsistency for Instance $Inst_Id and Volume $Vol_Id in region $rgn" >> "$TFDIR"/"$account"-inconsistent_tmp.txt
            echo -e "Instance_Environment_Tag: $iTagEnv vs Volume_Environment_Tag: $vTagEnv" >> "$TFDIR"/"$account"-inconsistent_tmp.txt
            if [ "$rponlyFlag" != "1" ]; then
              ec2-create-tags -O $AK -W $SAK --region $rgn "$Vol_Id" --tag "Environment=$iTagEnv"
              echo -e "\nUpdated Environment tag for Volume $Vol_Id to $iTagEnv\n" >> "$TFDIR"/"$account"-inconsistent_tmp.txt 
	    fi  
          fi
          if [ "$iTagApp" != "$vTagApp" ] && [ -z "$vTagApp" ]
          then
            echo -e "Tagging Inconsistency for Instance $Inst_Id and Volume $Vol_Id in region $rgn" >> "$TFDIR"/"$account"-inconsistent_tmp.txt
            echo -e "Instance_Application_Tag: $iTagApp vs Volume_Application_Tag: $vTagApp" >> "$TFDIR"/"$account"-inconsistent_tmp.txt
            if [ "$rponlyFlag" != "1" ]; then
              ec2-create-tags -O $AK -W $SAK --region $rgn "$Vol_Id" --tag "Application=$iTagApp"
              echo -e "\nUpdated Application tag for Volume $Vol_Id to $iTagApp\n" >> "$TFDIR"/"$account"-inconsistent_tmp.txt 
	    fi  
          fi
        else
       # Update Non-empty Volume Tags as well
         if [ "$iTagPlat" != "$vTagPlat" ]
         then
           echo -e "Tagging Inconsistency for Instance $Inst_Id and Volume $Vol_Id in region $rgn" >> "$TFDIR"/"$account"-inconsistent_tmp.txt
           echo -e "Instance_Platform_Tag: $iTagPlat vs Volume_Platform_Tag: $vTagPlat" >> "$TFDIR"/"$account"-inconsistent_tmp.txt
	   if [ "$rponlyFlag" != "1" ]; then
             ec2-create-tags -O $AK -W $SAK --region $rgn "$Vol_Id" --tag "Platform=$iTagPlat"
             echo -e "\nUpdated Platform tag for Volume $Vol_Id to $iTagPlat \n" >> "$TFDIR"/"$account"-inconsistent_tmp.txt 
           fi
         fi
         if [ "$iTagEnv" != "$vTagEnv" ]
         then
           echo -e "Tagging Inconsistency for Instance $Inst_Id and Volume $Vol_Id in region $rgn" >> "$TFDIR"/"$account"-inconsistent_tmp.txt
           echo -e "Instance_Environment_Tag: $iTagEnv vs Volume_Environment_Tag: $vTagEnv" >> "$TFDIR"/"$account"-inconsistent_tmp.txt
           if [ "$rponlyFlag" != "1" ]; then
             ec2-create-tags -O $AK -W $SAK --region $rgn "$Vol_Id" --tag "Environment=$iTagEnv"
             echo -e "\nUpdated Environment tag for Volume $Vol_Id to $iTagEnv\n" >> "$TFDIR"/"$account"-inconsistent_tmp.txt 
	   fi
         fi
         if [ "$iTagApp" != "$vTagApp" ]
         then
           echo -e "Tagging Inconsistency for Instance $Inst_Id and Volume $Vol_Id in region $rgn" >> "$TFDIR"/"$account"-inconsistent_tmp.txt
           echo -e "Instance_Application_Tag: $iTagApp vs Volume_Application_Tag: $vTagApp" >> "$TFDIR"/"$account"-inconsistent_tmp.txt
           if [ "$rponlyFlag" != "1" ]; then
             ec2-create-tags -O $AK -W $SAK --region $rgn "$Vol_Id" --tag "Application=$iTagApp"
             echo -e "\nUpdated Application tag for Volume $Vol_Id to $iTagApp\n" >> "$TFDIR"/"$account"-inconsistent_tmp.txt 
           fi
         fi
       fi

      done
      # ec2-describe-volumes -O $AK -W $SAK --region $rgn | grep "available" | awk '{ print $2 }' >> "$TFDIR"/"$account"-unattached.txt 
    done
    if [ ! -s "$TFDIR"/"$account"-inconsistent_tmp.txt ]
    then
      echo -e "No discrepancies in tagging of volumes found for $account account\n" >> "$TFDIR"/"$account"-inconsistent.txt
      NO_DISC_COUNT=$(($NO_DISC_COUNT+1))
    else 
      cat "$TFDIR"/"$account"-inconsistent_tmp.txt >> "$TFDIR"/"$account"-inconsistent.txt
    fi
done

/bin/chmod 777 "$TFDIR"/*inconsistent.txt
echo -e "From:$EMAIL_FROM" >> $TFDIR/vtem.txt
echo -e "To:$EMAIL_ID" >> $TFDIR/vtem.txt
echo -e "Subject: $SUBJECT" >> $TFDIR/vtem.txt
echo -e "Content-Type: text/plain" >> $TFDIR/vtem.txt
echo -e "The details about volume-tagging changes done by this script in various regions is as given below:\n" >> $TFDIR/vtem.txt

/bin/cat $TFDIR/*inconsistent.txt  >> $TFDIR/vtem.txt

if [ "$NO_DISC_COUNT" -lt "$ACCT_COUNT" ]
then
  /usr/sbin/sendmail -t < $TFDIR/vtem.txt
fi