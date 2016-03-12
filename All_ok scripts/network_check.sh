#!/bin/bash
#script to check if ping is working
#created on 03/25/2015
ping 8.8.8.8  
if [ $? != 0 ] ; then
ifdown eth1
ifup eth1
fi

#add the below line in crontab to get it scheduled for every 5 min
#*/5 * * * * /tmp/network_check.sh