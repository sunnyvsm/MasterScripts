#!/bin/bash
#to check if mysql user rro is assigned password

mysql_user=root
pwd=`mysql -u root -proot -e "select password from mysql.user where User='root'"`
if [ -z '$pwd' ] ; then
mysqladmin -u root password 'root'
fi

#check if database email_markting_8545 already exists
DBNAME="email_markting_8545"
TBNAME="datafile"
DBEXISTS=$(mysql -u root -proot --batch --skip-column-names -e "SHOW DATABASES LIKE '"$DBNAME"';" | grep "$DBNAME" > /dev/null; echo "$?")
TBEXISTS=$(mysql -u root -proot email_markting_8545 --batch --skip-column-names -e "SHOW TABLES LIKE '"$TBNAME"';" | grep "$TBNAME" > /dev/null; echo "$?")
if [ '$DBEXISTS' -eq 0 ];then
	if [ '$TBEXISTS'  -ne 0 ]; then 
		mysql -u root -proot email_markting_8545  < /tmp/email_markting_8545.sql
	fi
else
mysql -u root -proot -e "create database email_markting_8545; GRANT ALL PRIVILEGES ON email_markting_8545.* TO root@localhost IDENTIFIED BY 'root'"
mysql -u root -proot email_markting_8545  < /tmp/email_markting_8545.sql
fi
