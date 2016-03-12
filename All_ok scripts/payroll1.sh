writerc()
{
if [ $# -ne 4 ]
then
echo improper arguments
exit
fi
str=$1
row=$2
col=$3
attr=$4
tput cup $row $col
case $attr in
[bB])echo -ne "\033[1m$str";;
[nN])echo -ne "$str";;
esac
echo -ne "\033[0m"
}
writecentre()
{
if [ $# -ne 3 ]
then
echo improper arguments
exit
fi
str=$1
row=$2
attr=$3
length=`echo $str|wc -c`
col=`expr \( 80 - $length \) / 2`
tput cup $row $col
case $attr in
[bB])echo -ne "\033[1m$str";;
[nN])echo -ne "$str";;
esac
echo -ne "\033[0m"
}
madd.prg()
{
another=y
while [ "$another" = y -o "$another" = Y ]
do
clear
writerc "Payroll Processing System" 1 10 "B"
writerc "Add Records - Master File" 2 10 "B"
writerc "Employee Code: \c" 4 10 "B"
read e_empcode
if [ -z "$e_empcode" ]
then
exit
fi
a1z=`sqlplus -s payroll/123456 << abc
set heading off;
set verify off;
set pagesize 0
set feedback off;
select * from data where e_empcode=$e_empcode;
commit;
quit
abc`
echo $a1z > data.dat
grep \^$e_empcode data.dat > /dev/null
if [ $? -eq 0 ]
then
writerc "Code already exists. Press any key... " 20 10 "N"
read key
continue
fi
writerc "Name of employee: \c" 5 10 "B"
read e_empname
writerc "Sex: \c" 6 10 "B"
read e_sex
writerc "Address: \c" 7 10 "B"
read e_address
writerc "Name of city: \c" 8 10 "B"
read e_city
writerc "Pin code number: \c" 9 10 "B"
declare -i e_pin
read e_pin
if [ $e_pin -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 9 40 "B"
read e_pin
if [ $e_pin -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 9 95 "B"
declare +i e_pin
read e_pin
fi
fi
writerc "Department: \c" 10 10 "B"
read e_dept
writerc "Grade: \c" 11 10 "B"
read e_grade
writerc "GPF no: \c" 12 10 "B"
declare -i e_gpf_no
read e_gpf_no
if [ $e_gpf_no -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 12 40 "B"
read e_gpf_no
fi
if [ $e_gpf_no -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 12 95 "B"
declare +i e_gpf_no
read e_gpf_no
fi
writerc "GI scheme no: \c" 13 10 "B"
declare -i e_gis_no
read e_gis_no
if [ $e_gis_no -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 13 40 "B"
read e_gis_no
if [ $e_gis_no -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 13 95 "B"
declare +i e_gis_no
read e_gis_no
fi
fi
writerc "ESI scheme no: \c" 14 10 "B"
declare -i e_esis_no
read e_esis_no
if [ $e_esis_no -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 14 40 "B"
read e_esis_no
if [ $e_esis_no -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 14 95 "B"
declare +i e_esis_no
read e_esis_no
fi
fi
writerc "CL allowed: \c" 15 10 "B"
declare -i e_max_cl
read e_max_cl
if [ $e_max_cl -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric value: \c" 15 40 "B"
read e_max_cl
if [ $e_max_cl -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric value: \c" 15 95 "B"
declare +i e_max_cl
read e_max_cl
fi
fi
writerc "PL allowed: \c" 16 10 "B"
declare -i e_max_pl
read e_max_pl
if [ $e_max_pl -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric value: \c" 16 40 "B"
read e_max_pl
if [ $e_max_pl -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric value: \c" 16 95 "B"
declare +i e_max_pl
read e_max_pl
fi
fi
writerc "ML allowed: \c" 17 10 "B"
declare -i e_max_ml
read e_max_ml
if [ $e_max_ml -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 17 40 "B"
read e_max_ml
if [ $e_max_ml -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 17 95 "B"
declare +i e_max_ml
read e_max_ml
fi
fi
writerc "Basic Salary: \c" 18 10 "B"
declare -i e_bs
read e_bs
if [ $e_bs -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 18 40 "B"
read e_bs
if [ $e_bs -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 18 95 "B"
declare +i e_bs
read e_bs
fi
fi
e_cum_cl=0
e_cum_pl=0
e_cum_ml=0
e_cum_lwp=0
e_cum_att=0
b21a=`sqlplus -s payroll/123456 << abc
set feedback off
set pagesize 0
insert into data values($e_empcode,'$e_empname','$e_sex','$e_address','$e_city',$e_pin,'$e_dept','$e_grade',$e_gpf_no,$e_gis_no,$e_esis_no,$e_max_cl,$e_max_pl,$e_max_ml,$e_bs,$e_cum_cl,$e_cum_pl,$e_cum_ml,$e_cum_lwp,$e_cum_att);
commit;
quit
abc`
c21a=`echo $b21a|wc -c`
if [ $c21a -gt 1 ]
then
writerc "Data Not Inserted. Some value is Missing" 25 10 "B"
fi
writerc "Add another y/n \c" 30 10 "N"
read another
done
}
mmodi.prg()
{
another=y
while [ "$another" = y -o "$another" = Y ]
do
clear
writecentre "Payroll Processing System" 1 "B"
writecentre "Modify Records - Master File" 2 "B"
writerc "Employee Code: " 4 10 "B"
read e_empcode
if [ -z "$e_empcode" ]
then
exit
fi
a84a=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set pagesize 0
set verify off;
select * from data where e_empcode=$e_empcode;
commit;
quit
eof`
echo $a84a > data.dat
grep \^$e_empcode data.dat > /dev/null
if [ $? -ne 0 ]
then
writerc "Employee code does not exist.Press any key..." 10 10 "B"
read key
continue
fi
mline=`grep \^$e_empcode data.dat`
oldIFS="$IFS"
IFS=" "
set -- $mline
writerc "Name:$2 " 5 10 "N"
read e_empname
if [ -z "$e_empname" ]
then
e_empname=$2 
fi
writerc "Sex:$3 " 6 10 "N"
read e_sex       
if [ -z "$e_sex" ]
then
e_sex=$3
fi
writerc "Address:$4 " 7 10 "N"
read e_address
if [ -z "$e_address" ]
then
e_address=$4
fi
writerc "City:$5 " 8 10 "N"
read e_city
if [ -z "$e_city" ]
then
e_city=$5
fi
writerc "Pin code No:$6 " 9 10 "N"
read e_pin
if [ -z "$e_pin" ]
then
e_pin=$6
fi
writerc "Department:$7 " 10 10 "N"
read e_dept
if [ -z "$e_dept" ]
then
e_dept=$7
fi
writerc "Grade:$8 " 11 10 "N"
read e_grade
if [ -z "$e_grade" ]
then
e_grade=$8
fi
writerc "GPF no:$9 " 12 10 "N"
read e_gpf_no
if [ -z "$e_gpf_no" ]
then
e_gpf_no=$9
fi
shift 9
writerc "GI scheme no:$1 " 13 10 "N"
read e_gis_no
if [ -z "$e_gis_no" ]
then
e_gis_no=$1
fi
writerc "ESI sscheme no:$2 " 14 10 "N"
read e_esis_no
if [ -z "$e_esis_no" ]
then
e_esis_no=$2
fi
writerc "CL allowed:$3 " 15 10 "N"
read e_max_cl
if [ -z "$e_max_cl" ]
then
e_max_cl=$3
fi
writerc "PL allowed:$4 " 16 10 "N"
read e_max_pl
if [ -z "$e_max_pl" ]
then
e_max_pl=$4
fi
writerc "ML allowed:$5 " 17 10 "N"
read e_max_ml
if [ -z "$e_max_ml" ]
then
e_max_ml=$5
fi
writerc "Basic salary:$6 " 18 10 "N"
read e_bs
if [ -z "$e_bs" ]
then
e_bs=$6
fi
e_cum_cl=$7
e_cum_pl=$8
e_cum_ml=$9
shift 9
e_cum_lwp=$1
e_cum_att=$2
IFS="$oldIFS"
c45a=`sqlplus -s payroll/123456 << eof
set feedback off;
set verify off;
set pagesize 0
set heading off;
update data
set e_empname='$e_empname',e_sex='$e_sex',e_address='$e_address',e_city='$e_city',e_pin=$e_pin,e_dept='$e_dept',e_grade='$e_grade',e_gpf_no=$e_gpf_no,e_gis_no=$e_gis_no,e_esis_no=$e_esis_no,e_max_cl=$e_max_cl,e_max_pl=$e_max_pl,e_max_ml=$e_max_ml,e_bs=$e_bs,e_cum_cl=$e_cum_cl,e_cum_pl=$e_cum_pl,e_cum_ml=$e_cum_ml,e_cum_lwp=$e_cum_lwp,e_cum_att=$e_cum_att where e_empcode=$e_empcode;
commit;
quit
eof`
d21a=`echo $c45a|wc -c`
if [ $d21a -gt 1 ]
then
writerc "Data Not Updated" 20 10 "B"
fi
writerc "Modify Another y/n " 25 20 "N"
read another
done
}
mdel.prg()
{
another=y
while [ "$another" = y ]
do
clear
writecentre "Payroll Processing System" 1 "B"
writecentre "Delete Records - Master File" 3 "B"
writerc "Employee Code to Delete: \c" 6 10 "B"
read e_empcode
if [ -z "$e_empcode" ]
then
exit
fi
a98w=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set verify off;
set pagesize 0
select * from data where e_empcode=$e_empcode;
commit;
quit
eof`
echo $a98w > data.dat
grep \^$e_empcode data.dat > /dev/null
if [ $? -ne 0 ]
then
writerc "Employee code does not exist... press any key" 10 10 "B"
read key
continue
fi
tmp_val1=`sqlplus -s payroll/123456 << eof
set heading off
set feedback off
set pagesize 0
set verify off
delete from data where e_empcode=$e_empcode;
delete from tdata where t_empcode=$e_empcode;
delete from mdata where t_empcode=$e_empcode;
commit;
quit
eof`
writerc "Delete another y/n " 16 15 "B"
read another
done
}
mret.prg()
{
another=y
while [ "$another" = y -o "$another" = Y ]
do
clear
writecentre "Payroll Processing System" 1 "B"
writecentre "Retrieve Records - Master File" 3 "B"
writerc "Employee Code: " 4 10 "B"
read e_empcode
if [ -z "$e_empcode" ]
then
exit
fi
a87w=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set pagesize 0
set verify off;
select * from data where e_empcode=$e_empcode;
commit;
quit
eof`
echo $a87w > data.dat
grep \^$e_empcode data.dat > /dev/null
if [ $? -ne 0 ]
then
writerc "Employee code does not exist. Press any key..." 10 10 "B"
read key
continue
fi
mline=`grep \^$e_empcode data.dat`
oldIFS="$IFS"
IFS=" "
set -- $mline
writerc "Name: $2" 5 10 "N"
writerc "Sex: $3" 6 10 "N"
writerc "Address: $4" 7 10 "N"
writerc "City: $5" 8 10 "N"
writerc "Pin code No: $6" 9 10 "N"
writerc "Department: $7" 10 10 "N"
writerc "Grede: $8" 11 10 "N"
writerc "GPF no: $9" 12 10 "N"
shift 9
writerc "GI scheme no: $1" 13 10 "N"
writerc "ESI sscheme no: $2" 14 10 "N"
writerc "CL allowed: $3" 15 10 "N"
writerc "PL allowed: $4" 16 10 "N"
writerc "ML allowed: $5" 17 10 "N"
writerc "Basic salary: $6" 18 10 "N"
IFS="$oldIFS"
writerc "Retrieve another y/n " 20 20 "N"
read another
done
}


mde.prg()
{
while true
do
clear
writecentre "Payroll Processing System" 7 "B"
writecentre "Master File Data Entry" 8 "B"
writerc "\033[1mA\033[0mdd Records" 10 30 "N"
writerc "\033[1mM\033[0modify Records" 11 30 "N"
writerc "\033[1mD\033[0melete Record" 12 30 "N"
writerc "\033[1mR\033[0metrieve Record" 13 30 "N"
writerc "r\033[1mE\033[0mturn" 14 30 "N"
writerc "Your choice ?" 16 30 "N"
choice=""
while [ -z "$choice" ]
do
read choice
done
case "$choice" in
[Aa])madd.prg;;
[Mm])mmodi.prg;;
[Dd])mdel.prg;;
[Rr])mret.prg;;
[Ee])clear
break;;
*)echo \007;;
esac
done
}

################DONE UNDERSTANDING ###############
tadd.prg()
{
IFSspace="$IFS"
A="200 30 10 10 10 75 115 20"
B="200 25 10 10 10 75 115 20"
C="100 25 10 10 10 75 115 15"
D="100 22 10 10 10 75 115 15"
E="17 20 10 10 10 75 115 0"
another=y
t=`tty`
while [ "$another" = y -o "$another" = Y ]
do
clear
writecentre "Payroll Processing System" 1 "B"
writecentre "Add Records - Tran. File" 2 "B"
writerc "Employee Code: " 4 10 "B"
read t_empcode
if [ -z "$t_empcode" ]
then
exit
fi
a1z=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set pagesize 0
set verify off;
select * from data where e_empcode=$t_empcode;
commit;
quit
eof`
echo $a1z > data.dat
b1z=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set pagesize 0
set verify off;
select * from tdata where t_empcode=$t_empcode;
commit;
quit
eof`
echo $b1z > tdata.dat
mline=`grep \^$t_empcode data.dat`
if [ $? -ne 0 ]
then
writecentre "Coressponding Master record absent" 7 "N"
writecentre "Press any key..." 88888888 "N"
read key
continue
fi
grep \^$t_empcode tdata.dat > /dev/null
if [ $? -eq 0 ]
then
writecentre "Already exists, Cannot duplicate" 7 "N"
writecentre "Press any key..." 8 "N"
read key
continue
fi
writerc "Department: " 5 10 "B"
read t_dept
writerc "Casual leave: " 6 10 "B"
declare -i t_cl
read t_cl
if [ $t_cl -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 6 40 "B"
read t_cl
if [ $t_cl -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 6 95 "B"
declare +i t_cl
read t_cl
fi
fi
writerc "Medical leave: " 7 10 "B"
declare -i t_ml
read t_ml
if [ $t_ml -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 7 40 "B"
read t_ml
if [ $t_ml -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 7 95 "B"
declare +i t_ml
read t_ml
fi
fi
writerc "Provisional leave: " 8 10 "B"
declare -i t_pl
read t_pl
if [ $t_pl -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 8 40 "B"
read t_pl
if [ $t_pl -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 8 95 "B"
declare +i t_pl
read t_pl
fi
fi
writerc "LWP: " 9 10 "B"
declare -i t_lwp
read t_lwp
if [ $t_lwp -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 9 40 "B"
read t_lwp
if [ $t_lwp -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 9 95 "B"
declare +i t_lwp
read t_lwp
fi
fi
writerc "Special pay 1: " 10 10 "B"
declare -i t_sppay_1
read t_sppay_1
if [ $t_sppay_1 -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 10 40 "B"
read t_sppay_1
if [ $t_sppay_1 -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 10 95 "B"
declare +i t_sppay_1
read t_sppay_1
fi
fi
writerc "Special pay 2: " 11 10 "B"
declare -i t_sppay_2
read t_sppay_2
if [ $t_sppay_2 -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 11 40 "B"
read t_sppay_2
if [ $t_sppay_2 -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 11 95 "B"
declare +i t_sppay_2
read t_sppay_2
fi
fi
writerc "Income tax: " 12 10 "B"
declare -i t_inc_tax
read t_inc_tax
if [ $t_inc_tax -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 12 40 "B"
read t_inc_tax
if [ $t_inc_tax -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 12 95 "B"
declare +i t_inc_tax
read t_inc_tax
fi
fi
writerc "Rent deducation: " 13 10 "B"
declare -i t_rent_ded
read t_rent_ded
if [ $t_rent_ded -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 13 40 "B"
read t_rent_ded
if [ $t_rent_ded -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 13 95 "B"
declare +i t_rent_ded
read t_rent_ded
fi
fi
writerc "Long term loan: " 14 10 "B"
declare -i t_lt_loan
read t_lt_loan
if [ $t_lt_loan -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 14 40 "B"
read t_lt_loan
if [ $t_lt_loan -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 14 95 "B"
declare +i t_lt_loan
read t_lt_loan
fi
fi
writerc "short term loan: " 15 10 "B"
declare -i t_st_loan
read t_st_loan
if [ $t_st_loan -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 15 40 "B"
read t_st_loan
if [ $t_st_loan -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 15 95 "B"
declare +i t_st_loan
read t_st_loan
fi
fi
writerc "Special ded. 1: " 16 10 "B"
declare -i t_spded_1
read t_spded_1
if [ $t_spded_1 -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 16 40 "B"
read t_spded_1
if [ $t_spded_1 -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 16 95 "B"
declare +i t_spded_1
read t_spded_1
fi
fi
writerc "Special ded. 2: " 17 10 "B"
declare -i t_spded_2
read t_spded_2
if [ $t_spded_2 -eq 0 ]
then
writerc "Wrong Keyword Please Enter Only Numeric Value: \c" 17 40 "B"
read t_spded_2
if [ $t_spded_2 -eq 0 ]
then
writerc "Again Wrong Keyword Please Enter Only Numeric Value: \c" 17 95 "B"
declare +i t_spded_2
read t_spded_2
fi
fi
a24z=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set pagesize 0
set verify off;
insert into mdata values($t_empcode,'$t_dept',$t_cl,$t_ml,$t_pl,$t_lwp,$t_sppay_1,$t_sppay_2,$t_inc_tax,$t_rent_ded,$t_lt_loan,$t_st_loan,$t_spded_1,$t_spded_2);
commit;
quit
eof`
grade=`echo $mline|cut -d" " -f8`
bs=`echo $mline|cut -d" " -f15`
set -- `eval echo \\$$grade`
t_da=`echo "scale=2; $1 / 100.0 * $bs"|bc 2>/dev/null` 
t_hra=`echo "scale=2; $2 / 100.0 * $bs"|bc 2>/dev/null`
t_ca=`echo "scale=2; $3 / 100.0 * $bs"|bc 2>/dev/null`
t_cca=`echo "scale=2; $4 / 100.0 * $bs"|bc 2>/dev/null`
t_gs=`echo "scale=2; $bs + $t_da + $t_hra + $t_ca + $t_cca + $t_sppay_1 + $t_sppay_2"|bc 2>/dev/null`
t_gpf=`echo "scale=2; $5 / 100.0 * ($bs + $t_da)"|bc 2>/dev/null`
t_esis=$6
t_gis=$7 
t_prof_tax=$8
t_tot_ded=`echo "scale=2; $t_gpf + $t_esis + $t_gis + $t_prof_tax + $t_inc_tax + $t_lt_loan + $t_st_loan + $t_rent_ded + $t_spded_1 + $t_spded_2"|bc 2>/dev/null`
t_net_pay=`echo "scale=2; $t_gs - $t_tot_ded"|bc 2>/dev/null`
e14s=`sqlplus -s payroll/123456 << eof
set feedback off
set heading off
set verify off
set pagesize 0
insert into tdata values($t_empcode,'$t_dept',$t_cl,$t_ml,$t_pl,$t_lwp,$t_da,$t_hra,$t_ca,$t_cca,$t_sppay_1,$t_sppay_2,$t_gs,$t_gpf,$t_gis,$t_esis,$t_inc_tax,$t_prof_tax,$t_rent_ded,$t_lt_loan,$t_st_loan,$t_spded_1,$t_spded_2,$t_tot_ded,$t_net_pay);
commit;
quit
eof`
f4a=`echo $e14s|wc -c`
if [ $f4a -gt 1 ]
then
writerc "Data not inserted. Some value is Missing." 23 10 "B"
fi
days="31 28 31 30 31 30 31 31 30 31 30 31"
month=`date +%m`
totday=`echo $days|cut -d" " -f $month`
IFS="$IFSspace"
e_cum_att=0
net_day=`expr $totday - $t_cl - $t_ml - $t_pl - $t_lwp 2>/dev/null`
e_cum_att=`expr $e_cum_att + $net_day 2>/dev/null`
o124a=`sqlplus -s payroll/123456 << eof
set feedback off;
set verify off;
set heading off;
set pagesize 0
update data
set e_cum_cl=$t_cl,e_cum_pl=$t_pl,e_cum_ml=$t_ml,e_cum_lwp=$t_lwp,e_cum_att=$e_cum_att where e_empcode=$t_empcode;
commit;
quit
eof`
exec < $t
writerc "Add another y/n \c" 28 10 "N"
read another
done
}
tmodi.prg()
{
clear
another=y
t=`tty`
A="200 30 10 10 10 75 115 20"
B="200 25 10 10 10 75 115 20"
C="100 25 10 10 10 75 115 15"
D="100 22 10 10 10 75 115 15"
E="17 20 10 10 10 75 115 0"
while [ "$another" = y -o "$another" = Y ]
do
clear
writecentre "Payroll Processing System" 1 "B"
writecentre "Modify Records - tran. File" 2 "B"
writerc "Employee Code: " 4 10 "B"
read t_empcode
if [ -z "$t_empcode" ]
then
exit
fi
b54a=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set verify off;
set pagesize 0
select * from data where e_empcode=$t_empcode;
commit;
quit
eof`
echo $b54a > data.dat
a85a=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set pagesize 0
set verify off;
select * from mdata where t_empcode=$t_empcode;
commit;
quit
eof`
echo $a85a > mdata.dat
grep \^$t_empcode mdata.dat > /dev/null
if [ $? -ne 0 ]
then
writerc "Employee code does not exist.Press any key..." 10 10 "B"
read key
continue
fi
mline=`grep \^$t_empcode mdata.dat`
oldIFS="$IFS"
IFS=" "
set -- $mline
writerc "Department:$2 " 5 10 "N"
read t_dept
if [ -z "$t_dept" ]
then
t_dept=$2
fi
writerc "Casual Leave:$3 " 6 10 "N"
read t_cl
if [ -z "$t_cl" ]
then
t_cl=$3
fi
writerc "Medical Leave:$4 " 7 10 "N"
read t_ml
if [ -z "$t_ml" ]
then
t_ml=$4
fi
writerc "Provisional Leave:$5 " 8 10 "N"
read t_pl
if [ -z "$t_pl" ]
then
t_pl=$5
fi
writerc "LWP:$6 " 9 10 "N"
read t_lwp
if [ -z "$t_lwp" ]
then
t_lwp=$6
fi
writerc "Special Pay 1:$7 " 10 10 "N"
read t_sppay_1
if [ -z "$t_sppay_1" ]
then
t_sppay_1=$7
fi
writerc "Special Pay 2:$8 " 11 10 "N"
read t_sppay_2
if [ -z "$t_sppay_2" ]
then
t_sppay_2=$8
fi
writerc "Income Tax:$9 " 12 10 "N"
read t_inc_tax
if [ -z "$t_inc_tax" ]
then
t_inc_tax=$9
fi
shift 9
writerc "Rent Deducation:$1 " 13 10 "N"
read t_rent_ded
if [ -z "$t_rent_ded" ]
then
t_rent_ded=$1
fi
writerc "Long Term Loan:$2 " 14 10 "N"
read t_lt_loan
if [ -z "$t_lt_loan" ]
then
t_lt_loan=$2
fi
writerc "Short term Loan:$3 " 15 10 "N"
read t_st_loan
if [ -z "$t_st_loan" ]
then
t_st_loan=$3
fi
writerc "Special Ded 1:$4 " 16 10 "N"
read t_spded_1
if [ -z "$t_spded_1" ]
then
t_spded_1=$4
fi
writerc "Specail Ded 2:$5 " 17 10 "N"
read t_spded_2
if [ -z "$t_spded_2" ]
then
t_spded_2=$5
fi
aqw=`sqlplus -s payroll/123456 << eof
set heading off
set verify off
set pagesize 0
set feedback off
update mdata
set t_dept='$t_dept',t_cl=$t_cl,t_ml=$t_ml,t_pl=$t_pl,t_lwp=$t_lwp,t_sppay_1=$t_sppay_1,t_sppay_2=$t_sppay_2,t_inc_tax=$t_inc_tax,t_rent_ded=$t_rent_ded,t_lt_loan=$t_lt_loan,t_st_loan=$t_st_loan,t_spded_1=$t_spded_1,t_spded_2=$t_spded_2 where t_empcode=$t_empcode;
commit;
quit
eof`
line=`grep \^$t_empcode data.dat`
grade=`echo $line|cut -d" " -f8`
bs=`echo $line|cut -d" " -f15`
set -- `eval echo \\$$grade`
t_da=`echo "scale=2; $1 / 100.0 * $bs"|bc`
t_hra=`echo "scale=2; $2 / 100.0 * $bs"|bc`
t_ca=`echo "scale=2; $3 / 100.0 * $bs"|bc`
t_cca=`echo "scale=2; $4 / 100.0 * $bs"|bc`
t_gs=`echo "scale=2; $bs + $t_da + $t_hra + $t_ca + $t_cca + $t_sppay_1 + $t_sppay_2"|bc`
t_gpf=`echo "scale=2; $5 / 100.0 * ($bs + $t_da)"|bc`
t_esis=$6
t_gis=$7 
t_prof_tax=$8
t_tot_ded=`echo "$t_gpf + $t_esis + $t_gis + $t_prof_tax + $t_inc_tax + $t_lt_loan + $t_st_loan + $t_rent_ded + $t_spded_1 + $t_spded_2"|bc`
t_net_pay=`echo "$t_gs - $t_tot_ded"|bc`
guas=`sqlplus -s payroll/123456 << eof
set heading off
set feedback off
set verify off
set pagesize 0
update tdata
set t_dept='$t_dept',t_cl=$t_cl,t_ml=$t_ml,t_pl=$t_pl,t_lwp=$t_lwp,t_da=$t_da,t_hra=$t_hra,t_ca=$t_ca,t_cca=$t_cca,t_sppay_1=$t_sppay_1,t_sppay_2=$t_sppay_2,t_gs=$t_gs,t_gpf=$t_gpf,t_gis=$t_gis,t_esis=$t_esis,t_inc_tax=$t_inc_tax,t_prof_tax=$t_prof_tax,t_rent_ded=$t_rent_ded,t_lt_loan=$t_lt_loan,t_st_loan=$t_st_loan,t_spded_1=$t_spded_1,t_spded_2=$t_spded_2,t_tot_ded=$t_tot_ded,t_net_pay=$t_net_pay where t_empcode=$t_empcode;
commit;
quit
eof`
days="31 28 31 30 31 30 31 31 30 31 30 31"
month=`date +%m`
totday=`echo $days|cut -d" " -f $month`
e_cum_att=0
net_day=`expr $totday - $t_cl - $t_ml - $t_pl - $t_lwp`
e_cum_att=`expr $e_cum_att + $net_day`
qaq=`sqlplus -s payroll/123456 << eof
set feedback off;
set verify off;
set heading off;
set pagesize 0
update data
set e_cum_cl=$t_cl,e_cum_ml=$t_ml,e_cum_pl=$t_pl,e_cum_lwp=$t_lwp,e_cum_att=$e_cum_att where e_empcode=$t_empcode;
commit;
quit
eof`
exec < $t
writerc "Add another y/n " 33 10 "N"
read another
done
}
tdel.prg()
{
another=y
while [ "$another" = y -o "$another" = Y ]
do
clear
writecentre "Payroll proccessing System" 1 "B"
writecentre "Delete Records - Tran. File" 3 "B"
writerc "Employee code to Delete: \c" 6 10 "B"
read t_empcode
if [ -z "$t_empcode" ]
then
exit
fi
a=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set verify off;
set pagesize 0
select * from tdata where t_empcode=$t_empcode;
commit;
quit
eof`
echo $a > tdata.dat
grep \^$t_empcode tdata.dat > /dev/null
if [ $? -ne 0 ]
then
writerc "Employee code does not exists... Press any key" 10 10 "B"
read key
continue
fi
tmp_val2=`sqlplus -s payroll/123456 << eof
set heading off
set feedback off
set verify off
set pagesize 0
delete from tdata where t_empcode=$t_empcode;
delete from mdata where t_empcode=$t_empcode;
commit;
quit
eof`
e_cum_cl=0
e_cum_pl=0
e_cum_ml=0
e_cum_lwp=0
e_cum_att=0
tmp_val3=`sqlplus -s payroll/123456 << eof
set feedback off
set pagesize 0
update data set e_cum_cl=$e_cum_cl,e_cum_pl=$e_cum_pl,e_cum_ml=$e_cum_ml,e_cum_lwp=$e_cum_lwp,e_cum_att=$e_cum_att where e_empcode=$t_empcode;
quit
eof`
writerc "Delete another y/n " 16 15 "B"
read another
done
}
tret.prg()
{
another=y
while [ "$another" = y -o "$another" = Y ]
do
clear
writecentre "Payroll Maintenance System" 1 "B"
writecentre "Retrieve Record - Master File" 2 "B"
writerc "Employee code: " 4 10 "B"
read t_empcode
if [ -z "$t_empcode" ]
then
exit
fi
b=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set pagesize 0
set verify off;
select * from tdata where t_empcode=$t_empcode;
commit;
quit
eof`
echo $b > tdata.dat
grep \^$t_empcode tdata.dat > /dev/null
if [ $? -ne 0 ]
then
writerc "Employee code does not exists.Press any key..." 10 10 "B"
read key
continue
fi
mline=`grep \^$t_empcode tdata.dat`
oldIFS="$IFS"
IFS=" "
set -- $mline
writerc "Department: $2" 5 10 "N"
writerc "Casual leave: $3" 6 10 "N"
writerc "Medical leave: $4" 7 10 "N"
writerc "Provisional leave: $5" 8 10 "N"
writerc "LWP: $6" 9 10 "N"
writerc "Special pay 1: $7" 10 10 "N"
writerc "Special pay 2: $8" 11 10 "N"
writerc "Income tax: $9" 12 10 "N"
shift 9
writerc "Rent deducation: $1" 13 10 "N"
writerc "Long term loan: $2" 14 10 "N"
writerc "Short term loan: $3" 15 10 "N"
writerc "Special ded. 1: $4" 16 10 "N"
writerc "Special ded. 2: $5" 17 10 "N"
writerc "Total DA: $6" 18 10 "N"
writerc "Total HRA: $7" 19 10 "N"
writerc "Total CA: $8" 20 10 "N"
writerc "Total CCA: $9" 21 10 "N"
shift 9
writerc "Total GS: $1" 22 10 "N"
writerc "Total GPF: $2" 23 10 "N"
writerc "Total ESIS: $3" 24 10 "N"
writerc "Total GIS: $4" 25 10 "N"
writerc "Total Prof Tax: $5" 26 10 "N"
writerc "Total Net Pay: $6" 27 10 "N"
IFS="$oldIFS"
writerc "Retrieve another y/n " 35 20 "N"
read another
done
}
tde.prg()
{
while true
do
clear
writecentre "Payroll Processing System" 7 "B"
writecentre "Transaction Data Entry" 8 "B"
writerc "\033[1mA\033[0mdd Records" 10 30 "N"
writerc "\033[1mM\033[0modify Records" 11 30 "N"
writerc "\033[1mD\033[0melete Record" 12 30 "N"
writerc "\033[1mR\033[0metrieve Record" 13 30 "N"
writerc "r\033[1mE\033[0mturn" 14 30 "N"
writerc "Your choice ?" 16 30 "N"
choice=""
while [ -z "$choice" ]
do
read choice
done
case "$choice" in
[Aa])tadd.prg;;
[Mm])tmodi.prg;;
[Dd])tdel.prg;;
[Rr])tret.prg;;
[Ee])clear
break;;
*)echo \007;;
esac
done
}
dboper.prg()
{
while true
do
clear
writecentre "Payroll Processing System" 7 "B"
writecentre "Data Base Operation" 8 "B"
writerc "\033[1mM\033[0master File Data Entry" 10 30 "N"
writerc "\033[1mT\033[0mransaction Data Entry" 11 30 "N"
writerc "\033[1mR\033[0meturn to Main Menu" 12 30 "N"
writerc "Your choice ?" 15 30 "N"
choice=""
while [ -z "$choice" ]
do
read choice
done
case "$choice" in
[Mm])mde.prg;;
[Tt])tde.prg;;
[Rr])clear
break;;
*)echo \007;;
esac
done
}
maillbl.prg()
{
clear
t=`tty`
writerc "Please wait... " 12 22 "B"
rm data.dat
a=`sqlplus -s payroll/123456 << eof
set heading off
set pagesize 0
set feedback off
select e_empcode from data;
quit
eof`
for i in `echo $a`
do
b=`sqlplus -s payroll/123456 << eof
set heading off
set pagesize 0
set feedback off
select * from data where e_empcode=$i;
quit
eof`
echo $b >> data.dat
done
exec < data.dat
while true
do
read line1
if [ $? -eq 0 ]
then
name1=`echo $line1|cut -d":" -f2`
add1=`echo $line1|cut -d":" -f4`
city1=`echo $line1|cut -d":" -f5`
pin1=`echo $line1|cut -d":" -f6`
ln1=`echo $name1|wc -c`
la1=`echo $add1|wc -c`
lc1=`echo $city1|wc -c`
lp1=`echo $pin1|wc -c`
bn1=`expr 40 - $ln1`
ba1=`expr 40 - $la1`
bc1=`expr 40 - $lc1`
bp1=`expr 40 - $lp1`
count=1
while [ $count -le $bn1 ]
do
name1="$name1 "
count=`expr $count + 1`
done
count=1
while [ $count -le $ba1 ]
do
add1="$add1 "
count=`expr $count + 1`
done
count=1
while [ $count -le $bc1 ]
do
city1="$city1 "
count=`expr $count + 1`
done
count=1
while [ $count -le $bp1 ]
do
pin1="$pin1 "
count=`expr $count + 1`
done
else
break
fi
line2=""
read line2
name2=`echo $line2|cut -d":" -f2`
add2=`echo $line2|cut -d":" -f4`
city2=`echo $line2|cut -d":" -f5`
pin2=`echo $line2|cut -d":" -f6`
echo "$name1 $name2" >> mail.lbi
echo "$add1 $add2" >> mail.lbi
echo "$city1 $city2" >> mail.lbi
echo "$pin1 $pin2" >> mail.lbi
echo >> mail.lbi
done
exec < $t
if [ "$ans" = S -o "$ans" = s ]
then
echo 
pg mail.lbi
else
lpr mail.lbi
fi
rm mail.lbi
}
lsr.prg()
{
clear
another=y
t=`tty`
month=`date +%B`
IFSspace="$IFS"
while [ "$another" = y -o "$another" = Y ]
do
clear
writecentre "Payroll Processing System" 1 "B"
writecentre "Leave Status Report" 2 "B"
writerc "Employee code: " 4 10 "B"
read empcode
if [ -z "$empcode" ]
then
exit
fi
b45q=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set pagesize 0
set verify off;
select * from data where e_empcode=$empcode;
commit;
quit
eof`
echo $b45q > data.dat
grep \^$empcode data.dat > /dev/null
if [ $? -ne 0 ]
then
writerc "Employee code does not exist. Press any key..." 10 10 "B"
read key
continue
fi
IFS=" "
exec < data.dat
while read e_empcode e_empname e_sex e_address e_city e_pin e_dept e_grade e_gpf_no e_gis_no e_esis_no e_max_cl e_max_pl e_max_ml e_bs e_cum_cl e_cum_pl e_cum_ml e_cum_lwp e_cum_att
do
if [ "$empcode" = "$e_empcode" ]
then
break
fi
done
exec < $t
IFS="$IFSspace"
bal_cl=`expr $e_max_cl - $e_cum_cl`
bal_ml=`expr $e_max_ml - $e_cum_ml`
bal_pl=`expr $e_max_pl - $e_cum_pl`
writerc "                             " 4 1 "N"
writerc "\033[1mName:\033[0m$e_empname" 5 1 "N"
writerc "\033[1mEmpcode:\033[0m$e_empcode" 5 15 "N"
writerc "\033[1mGrade:\033[0m$e_grade" 5 35 "N"
writerc "\033[1mMonth:\033[0m$month" 5 55 "N"
writerc "CL Allowed" 7 1 "B"
writerc "ML Allowed" 7 15 "B"
writerc "PL Allowed" 7 35 "B"
writerc "$e_max_cl" 8 1 "N"
writerc "$e_max_ml" 8 15 "N"
writerc "$e_max_pl" 8 35 "N"
writerc "Cum.CI" 10 1 "B"
writerc "Cum.ML" 10 15 "B"
writerc "Cum.PL" 10 35 "B"
writerc "Cum.LWP" 10 55 "B"
writerc "Cum.Att.Days" 10 66 "B"
writerc "$e_cum_cl" 11 1 "N"
writerc "$e_cum_ml" 11 15 "N"
writerc "$e_cum_pl" 11 35 "N"
writerc "$e_cum_lwp" 11 55 "N"
writerc "$e_cum_att" 11 66 "N"
writerc "Balance CL" 13 1 "B"
writerc "Balance ML" 13 15 "B"
writerc "Balance PL" 13 35 "B"
writerc "$bal_cl" 14 1 "N"
writerc "$bal_ml" 14 15 "N"
writerc "$bal_pl" 14 35 "N"
writerc "Another employee y/n " 21 10 "N"
read another
done
}
payprint.prg()
{
clear
month=`date +%B`
days="31 29 31 30 31 30 31 31 30 31 30 31"
tmp=`date +%m`
mdays=`echo $days|cut -d" " -f$tmp`
another=y
t=`tty`
while [ "$another" = y ]
do
clear
writecentre "Payroll Processing System" 1 "B"
writecentre "Pay Sheet" 2 "B"
writerc "Employee Code: " 4 10 "B"
read empcode
if [ -z "$empcode" ]
then
exit
fi
a65q=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set verify off;
set pagesize 0
select * from data where e_empcode=$empcode;
quit
eof`
echo $a65q > data.dat
b82q=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set verify off;
set pagesize 0
select * from tdata where t_empcode=$empcode;
quit
eof`
echo $b82q > tdata.dat
grep \^$empcode tdata.dat > /dev/null
if [ $? -ne 0 ]
then
writerc "Employee code does not exists. Press any key... " 10 10 "B"
read key
clear
continue
fi
dln="-"
count=0
while [ $count -lt 88 ]
do
dln="$dln-"
count=`expr $count + 1`
done
clear
writerc "$dln" 0 1 "B"
writecentre "Shively & Brett Pvt. Ltd." 1 "B"
writerc "$dln" 2 1 "B"
exec < data.dat
while read e_empcode e_empname e_sex e_address e_city e_pin e_dept e_grade e_gpf_no e_gis_no e_esis_no e_max_cl e_max_pl e_max_ml e_bs e_cum_cl e_cum_pl e_cum_ml e_cum_lwp e_cum_att
do
if [ "$empcode" = "$e_empcode" ]
then
break
fi
done
exec < tdata.dat
while read t_empcode t_dept t_cl t_ml t_pl t_lwp t_da t_hra t_ca t_prof_tax t_cca t_sppay_1 t_sppay_2 t_gs t_gpf t_gis t_esis t_inc_tax t_rent_ded t_lt_loan t_st_loan t_spded_1 t_spded_2 t_tot_ded t_net_pay
do
if [ "$empcode" = "$t_empcode" ]
then
break
fi
done
exec < $t
writerc "Employee code:\033[0m$e_empcode" 3 1 "B"
writerc "\033[1mGrade:\033[0m$e_grade" 3 40 "N"
writerc "\033[1mMonth:\033[0m$month" 3 70 "N"
writerc "\033[1mName:\033[0m$e_empname" 5 1 "N"
writerc "\033[1mSex:\033[0m$e_sex" 5 40 "N"
writerc "\033[1mDepartment:\033[0m$e_dept" 5 70 "N"
writerc "\033[1mGPF No:\033[0m$e_gpf_no" 7 1 "N"
writerc "\033[1mGIS No:\033[0m$e_gis_no" 7 40 "N"
writerc "\033[1mESIS No:\033[0m$e_esis_no" 7 70 "N"
writerc "Normal Days" 9 1 "B"
writerc "Casu Leav" 9 15 "B"
writerc "Medical Leave" 9 30 "B"
writerc "Prov Leave" 9 48 "B"
writerc "LWP" 9 65 "B"
writerc "Attended Days" 9 72 "B"
writerc "$mdays" 10 1 "B"
writerc "$t_cl" 10 18 "N"
writerc "$t_ml" 10 30 "N"
writerc "$t_pl" 10 48 "N"
writerc "$t_lwp" 10 65 "N"
writerc "$e_cum_att" 10 72 "N"
writerc "BS" 12 1 "B"
writerc "DA" 12 10 "B"
writerc "HRA" 12 25 "B"
writerc "CA" 12 35 "B"
writerc "CCA" 12 48 "B"
writerc "S.P.1" 12 56 "B"
writerc "S.P.2" 12 65 "B"
writerc "GS" 12 75 "B"
writerc "$e_bs" 13 1 "N"
writerc "$t_da" 13 10 "N"
writerc "$t_hra" 13 25 "N"
writerc "$t_ca" 13 35 "N"
writerc "$t_cca" 13 48 "N"
writerc "$t_sppay_1" 13 56 "N"
writerc "$t_sppay_2" 13 65 "N"
writerc "$t_gs" 13 75 "N"
writerc "GPF" 15 1 "B"
writerc "ESIS" 15 10 "B"
writerc "GIS" 15 18 "B"
writerc "IT" 15 25 "B"
writerc "PT" 15 32 "B"
writerc "RENT" 15 41 "B"
writerc "Loan1" 15 48 "B"
writerc "Loan2" 15 58 "B"
writerc "S.S.1" 15 65 "B"
writerc "S.S.2" 15 74 "B"
writerc "Total" 15 82 "B"
writerc "$t_gpf" 16 1 "N"
writerc "$t_esis" 16 10 "N"
writerc "$t_gis" 16 18 "N"
writerc "$t_inc_tax" 16 25 "N"
writerc "$t_prof_tax" 16 32 "N"
writerc "$t_rent_ded" 16 41 "N"
writerc "$t_lt_loan" 16 48 "N"
writerc "$t_st_loan" 16 58 "N"
writerc "$t_spded_1" 16 65 "N"
writerc "$t_spded_2" 16 74 "N"
writerc "$t_tot_ded" 16 82 "N"
writerc "Net Pay" 18 1 "B"
writerc "Rs. $t_net_pay" 19 1 "N"
writerc "Receiver's Signature" 19 68 "N"
writerc "$dln" 20 1 "N"
writerc "Want to dispaly another payslip y/n " 22 10 "N"
read another
done
}
spaysheet.prg()
{
clear
dept="mfg:assly:stores:maint:accts"
t=`tty`
IFSspace="$IFS"
IFScolon=" "
month=`date +%B`
year=`date +%Y`
writecentre "Payroll Processing System" 1 "B"
writecentre "Summary Payroll Sheet" 2 "B"
writecentre "$month $year" 3 "B"
writerc "Total" 5 20 "B"
writerc "Gross" 5 35 "B"
writerc "Gross" 5 50 "B"
writerc "Net" 5 70 "B"
writerc "Department" 6 5 "B"
writerc "Employee" 6 20 "B"
writerc "Earning" 6 35 "B"
writerc "Deducation" 6 50 "B"
writerc "payments" 6 70 "B"
count=1
row=8
while [ $count -le 5 ]
do
var=`echo $dept|cut -d":" -f$count`
a=`sqlplus -s payroll/123456 << eof
set heading off
set feedback off
set pagesize 0
set verify off
select count(t_dept),sum(t_gs),sum(t_tot_ded),sum(t_net_pay) from tdata where t_dept='$var';
commit;
quit
eof`
echo $a > data.dat
set `cat data.dat`
writerc "$var" $row 5 "N"
writerc "$1" $row 20 "N"
writerc "$2" $row 35 "N"
writerc "$3" $row 50 "N"
writerc "$4" $row 70 "N"
IFS="$IFSspace"
row=`expr $row + 1`
count=`expr $count + 1`
let i++
done
IFS="$IFSspace"
writerc "Press any key..." 24 15 "N"
read key
}
reports.prg()
{
while true
do
clear
writerc "\033[36mPayroll Processing System\033[37m" 7 30 "B"
writerc "\033[36mReport Menu\033[37m" 8 30 "N"
writerc "\033[1mM\033[0maling Labels" 10 30 "N"
writerc "\033[1mL\033[0meave Status Report" 11 30 "N"
writerc "\033[1mP\033[0maysheet Printing" 12 30 "N"
writerc "\033[1mS\033[0mummary Payroll Sheet" 13 30 "N"
writerc "\033[1mR\033[0meturn to Main Menu" 14 30 "N"
writerc "Your choice ?" 16 30 "N"
choice=""
while [ -z "$choice" ]
do
read choice
done
case "$choice" in 
[Mm])maillbl.prg;;
[Ll])lsr.prg;;
[Pp])payprint.prg;;
[Ss])spaysheet.prg;;
[Rr])clear
break;;
*)echo \007;;
esac
done 
}
clmonth.prg()
{
clear
writecentre "Payroll Processing System" 2 "B"
writecentre "Close Current Month" 3 "B"
set `date`
cur_mth=$2
if [ -f etran$cur_mth.dat ]
then
writecentre "Month has already been closed. Press any key..." 15 "B"
read key
exit
fi
a78q=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set verify off;
set pagesize 0
select count(*) from data;
commit;
quit
eof`
b87q=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set verify off;
set pagesize 0
select count(*) from tdata;
commit;
quit
eof`
if [ $a78q -gt $b87q ]
then
writecentre "Transacation file incomplete.Cannot close month." 15 "B"
writecentre "Press any key..." 16 "B"
read key
exit
fi
tmp_val4=`sqlplus -s payroll/123456 << eof
set heading off;
set feedback off;
set verify off;
set pagesize 0
insert into etran$cur_mth select * from tdata;
truncate table tdata;
truncate table mdata;
commit;
quit
eof`
touch etran$cur_mth.dat
if [ $? -eq 0 ]
then
writecentre "Month successfully closed... Press any key" 15 "B"
else
writecentre "Unable to close month... Press any key" 15 "B"
fi
read key
}
clyear.prg()
{
clear
writecentre "Payroll processing System" 2 "B"
writecentre "close Year $ Reoraginze" 3 "B"
t=`tty`
writecentre "Please wait...trying to close year" 10 "B"
yr=`date +%y`
if [ -f "etran$yr.dat" ]
then
writecentre "Year has already been closed. Press any key..." 12 "B"
read key
exit
fi
month="Apr:May:Jun:Jul:Aug:Sep:Oct:Nov:Dec:Jan:Feb:Mar"
IFS=":"
set $month
count=1
flag=0
while [ "$count" -le 12 ]
do
if [ -f "etran$1.dat" ]
then
tmp_val5=`sqlplus -s payroll/123456 << eof
set heading off
set feedback off
set verify off
set pagesize 0
insert into etran$yr select * from etran$1;
truncate table etran$1;
commit;
quit
eof`
rm etran$1.dat
touch etran$yr.dat
flag=1
fi
count=`expr $count + 1`
shift
done
if [ $flag = 0 ]
then
writecentre "Month has not been closed. Press any key..." 12 "B"
writecentre "Close month before closing year.Press any key..." 12 "B"
read key
exit
fi
IFS=" "
a=`sqlplus -s payroll/123456 << eof
set heading off
set pagesize 0
set feedback off
select e_empcode from data;
quit
eof`
echo $a > data.dat
cat data.dat|while read line
do
e_cum_cl=0
e_cum_pl=0
e_cum_ml=0
e_cum_lwp=0
e_cum_att=0
tmp_val6=`sqlplus -s payroll/123456 << eof
set feedback off
set pagesize 0
update data set e_cum_cl=$e_cum_cl,e_cum_pl=$e_cum_pl,e_cum_ml=$e_cum_ml,e_cum_lwp=$e_cum_lwp,e_cum_att=$e_cum_att where e_empcode=$line;
quit
eof`
done
exec < $t
writecentre "Year has been closed successfully. Press any key..." 12 "B"
read key
}
sysmnt.prg()
{
while true
do
clear
writerc "\033[36mPayroll Processing System\033[37m" 7 27 "B"
writerc "\033[32mSystem Maintenance Menu\033[37m" 8 28 "N"
writerc "c\033[1mL\033[0mose month" 10 30 "N"
writerc "\033[1mC\033[0mlose year & reorganise" 11 30 "N"
writerc "\033[1mR\033[0metrun to main menu" 12 30 "N"
writerc "Your choice ?" 14 30 "N"
choice=""
while [ -z "$choice" ]
do
read choice
done
case "$choice" in 
[Ll])clmonth.prg;;
[Cc])clyear.prg;;
[Rr])clear
break;;
*)echo \007;;
esac
done 
}
while true
do
clear
writecentre "Payroll Processing System" 7 "B" 
writecentre "Main Menu" 8 "N"
writerc "\033[1mD\033[0matabase operations" 10 30 "N"
writerc "\033[1mR\033[0meports" 11 30 "N"
writerc "\033[1mS\033[0mystem maintenance" 12 30 "N"
writerc "\033[1mE\033[0mxit" 13 30 "N"
writerc "Your Choice ? " 15 30 "N"
choice=""
while [ -z "$choice" ]
do
read choice
done
case "$choice" in
[Dd])dboper.prg;;
[Rr])reports.prg;;
[Ss])sysmnt.prg;;
[Ee])clear
exit;;
*)echo \007;;
esac
done
