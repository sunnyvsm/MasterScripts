#!/bin/bash

. /etc/rc.d/init.d/functions
. /home/lucidmedia/upload/udbfunctions

SSH_OPTS="-o StrictHostKeychecking=no -o connectTimeout=10 -o ServerAliveInterval=300"

HOME_DIR="/home/lucidmedia"
TMP_DIR="${HOME_DIR}/tmp"
REDIS_DIR="/usr/local/redis"
DATE="`date +%m-%d-%Y-%H-%M-%S`"
LOG_DIR="${HOME_DIR}/logs"
LOG_FILE="${LOG_DIR}/${DATE}-udb.log"
TIME_STAMP="`date +%m-%d-%Y\" \"%I:%M`"
SSH_USER="lucidmedia"
ERR=0
EMAIL="lucid-support@dinoct.com"

mkdir -p ${LOG_DIR} ${TMP_DIR}

function get_keys()
{
        local host=$1
        local port=$2
        local pid=0
        local pidStatus=1

        echo -n "Getting keys from $host-$port: "
        $REDIS_DIR/bin/redis-cli -h $host -p $port keys "*" | sed 's/ /\n/g' > $TMP_DIR/keys.$host.$port.txt &
        #/usr/local/redis-2.2_x64/bin/redis-cli -h $host -p $port keys "*" | sed 's/ /\n/g' > $TMP_DIR/keys.$host.$port.txt &
        pid=$!
        echo -n .
        while [ $pidStatus -eq 1 ];
        do
                sleep 5
                if ps -p $pid > /dev/null;then
                        echo -n .
                else
                        wait $pid
                        pidStatus=$?
                        if [ $pidStatus -eq 0 ];then
                                if [ `wc -l $TMP_DIR/keys.$host.$port.txt | awk '{print $1}'` -gt 0 ];then
                                        echo -en "ok\n"
                                        return 0
                                fi
                        else
                                echo -en "error\n"
                                return 1
                        fi
                fi
        done
        return 1
}

function clean_udb_java()
{
        local host=$1
        local port=$2
        local stamp="`date +%m-%d-%Y-%H-%M-%S`"
        local timeout=720
        local pre_nol=0
        local post_nol=0
        local log_file="$LOG_DIR/udb-cleaner-$host-$port-$stamp.txt"
        local retry=3

        echo -n "Running UDB Cleaner $host-$port: "
        rm -f /home/lucidmedia/ClickSense/tomcat/webapps/ROOT/WEB-INF/lib/heritrix-*.jar
        java -Xmx1g -cp "/usr/local/tomcat/lib/*:/home/lucidmedia/ClickSense/tomcat/webapps/ROOT/WEB-INF/lib/*:/home/lucidmedia/ClickSense/tomcat/webapps/ROOT/WEB-INF/classes" -Dclicksense.application.home=/home/lucidmedia/ClickSense -Dspring.profiles.active=datacenter.aws.dsp.us.virginia,deployment.standard com.lucidmedia.dsp.ud.tools.UserDatabaseCleanerByTimeStamp 21 $TMP_DIR/keys.$host.$port.txt >$log_file 2>$log_file &
        sleep 10
        while [ $timeout -gt 0 ];
        do
                echo -n .
                pre_nol=`wc -l $log_file 2>/dev/null | awk '{print $1}'`
                sleep 15
                post_nol=`wc -l $log_file 2>/dev/null | awk '{print $1}'`
                if [ -z $pre_nol ] || [ -z $post_nol ];then
                        echo -n "retrying-$retry"
                        let retry=${retry}-1
                        if [ $retry -eq 0 ];then
                                echo -en "error\n"
                                return 1
                        fi
                else
                        if [ $pre_nol -eq $post_nol ];then
                                echo -en "ok\n"
                                local pid=`ps -ef | grep java | grep $port | grep -v 'grep' | awk '{print $2}'`
                                if [ ! -z "$pid" ];then
                                        kill -9 $pid
                                fi
                                return 0
                        fi
                fi
                let timeout=${timeout}-1
        done
        if [ $timeout -eq 0 ];then
                echo -en "timeout\n"
        fi
        return 1
}

function clean_shard()
{
        local host=$1
        local port=$2

        #rewrite_aof $host $port
        #if [ $? -ne 0 ];then
        #       return 1
        #fi

        get_keys $host $port
        if [ $? -ne 0 ];then
                return 1
        fi

        clean_udb_java $host $port
        if [ $? -ne 0 ];then
                return 1
        fi

        rewrite_aof $host $port
        if [ $? -ne 0 ];then
                return 1
        fi
}

function clean()
{
        local host=$1
        local errFlag=0
        local range="seq $2 $3"
        local slave=`echo $host | sed 's/usvalumu/usorlusu/g'`

        echo "Cleanup started at :" `date`
        echo "Memory usage before cleanup:"
        ssh $SSH_OPTS $host "free"

        local used_mem=`ssh $SSH_OPTS $host "free | grep "Mem:""|awk '{print $3}'`
        local buffer_mem=`ssh $SSH_OPTS $host "free | grep "Mem:""|awk '{print $6}'`
        local cached_mem=`ssh $SSH_OPTS $host "free | grep "Mem:""|awk '{print $7}'`
        local total_mem=`ssh $SSH_OPTS $host "free | grep "Mem:""|awk '{print $2}'`
        local mem_used_before=`echo "scale=4; (($used_mem-$buffer_mem-$cached_mem) / $total_mem)*100"| bc`
        echo "Memory usage before cleanup = $mem_used_before %"

        echo "--------------------------------------------------------------------------"

        for port in `$range`
        do
                clean_shard $host $port
                if [ $? -ne 0 ]; then
                        errFlag=1
                        continue
                fi

                stop_redis $host $port
                if [ $? -ne 0 ]; then
                        errFlag=1
                        continue
                fi

                start_redis $host $port
                if [ $? -ne 0 ]; then
                        errFlag=1
                        continue
                fi

                stop_redis $slave $port
                ssh $SSH_OPTS $slave "rm -f /usr/local/redis/data/$port/*"
                start_redis $slave $port
        done

        echo "--------------------------------------------------------------------------"
        echo "Cleanup Completed at :" `date`
        echo "Memory usage after cleanup:"
        ssh $SSH_OPTS $host "free"

        local used_mem=`ssh $SSH_OPTS $host "free | grep "Mem:""|awk '{print $3}'`
        local buffer_mem=`ssh $SSH_OPTS $host "free | grep "Mem:""|awk '{print $6}'`
        local cached_mem=`ssh $SSH_OPTS $host "free | grep "Mem:""|awk '{print $7}'`
        local total_mem=`ssh $SSH_OPTS $host "free | grep "Mem:""|awk '{print $2}'`
        local mem_used_after=`echo "scale=4; (($used_mem-$buffer_mem-$cached_mem) / $total_mem)*100"| bc`
        echo "Memory usage after cleanup = $mem_used_after %"
        freed_mem=`echo "scale=4; $mem_used_before - $mem_used_after"| bc`
        echo "Cleaned up memory in percentage = $freed_mem %"

        if [ $errFlag -eq 1 ];then
                return 1
        fi
}

if [ $# -ne 3 ];then
        echo "Invalid number of arguments: <udb master> <start port> <end port>"
else
        echo "Cleaning $1..."
        clean $1 $2 $3
        if [ $? -ne 0 ];then
                echo "ERROR Running UDB Cleaner on $1"
                ERR=1
        fi
fi

if [ $ERR -eq 1 ];then
        SUB="ERROR"
else
        SUB="OK"
fi

#echo "$SUB" | mail -s "$SUB: UDB Cleaner $2" ${EMAIL}
mail -s "$SUB: UDB Cleaner $1" ${EMAIL} < /home/lucidmedia/$1.log