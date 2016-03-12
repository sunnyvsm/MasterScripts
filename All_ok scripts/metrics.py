#!/usr/bin/env python
from __future__ import print_function
import os
import sys
import time
import sqlite3 as lite

# read metrics from stdin and push them into a sqlite db
# run aggs off the sqlite db
# input:
# servers.us-east-1.vADS.Production.AdserverOpenRTB-104.removeFlightMediaByCreativeTopicRule.TotalRequests 683
# servers.us-east-1.vADS.Production.AdserverOpenRTB-104.removeFlightMediaByCreativeTopicRule.TotalRequests 352
# servers.us-east-1.vADS.Production.AdserverOpenRTB-104.removeFlightMediaByCreativeTopicRule.TotalRequests 235

if os.isatty(file.fileno(sys.stdin)):
  print("no stdin... exit")
  exit(2)

timestamp = int(time.time())
con = None
con = lite.connect(':memory:')
cur = con.cursor()
cur.execute('create table metrics(metric text not null, value float not null);')
lines = sys.stdin.readlines()
for item in lines:
  try:
    item = item.rstrip()
    k,v = item.split(' ')
    cur.execute('insert into metrics (metric, value) values (?, ?)', (k,v) );
  except:
    print("malformed line:",item, file=sys.stderr)
con.commit()
cur.execute('select count(distinct metric), count(value) from metrics;')
num_metric = cur.fetchall()
for i in num_metric:
        metric_count1=i[0]
        value_count1=i[1]
        print (metric_count1)
        print (value_count1)
        cur.execute('select distinct metric, count(metric),min(value),max(value),avg(value),sum(value) from metrics group by metric;')
        metrics1 = cur.fetchall()
        for metric1 in metrics1:
                metric_name = metric1[0].replace("servers", "agg")
                print(metric_name)
                metric_count = metric1[1]
                metric_min = metric1[2]
                metric_max = metric1[3]
                metric_avg = metric1[4]
                metric_sum = metric1[5]
                cur.execute("select value from metrics where metric= (?) order by value asc limit 1 offset (?)*50/100-1;",(metric_name,metric_count1))
                metrics2 = cur.fetchall()
                cur.execute("select value from metrics where metric= (?) order by value asc limit 1 offset (?)*66/100-1;",(metric_name,metric_count1))
                metrics3 = cur.fetchall()
                cur.execute("select value from metrics where metric= (?) order by value asc limit 1 offset (?)*75/100-1;",(metric_name,metric_count1))
                metrics4 = cur.fetchall()
                cur.execute("select value from metrics where metric= (?) order by value asc limit 1 offset (?)*80/100-1;",(metric_name,metric_count1))
                metrics5 = cur.fetchall()
                cur.execute("select value from metrics where metric= (?) order by value asc limit 1 offset (?)*95/100-1;",(metric_name,metric_count1))
                metrics6 = cur.fetchall()
                cur.execute("select value from metrics where metric= (?) order by value asc limit 1 offset (?)*98/100-1;",(metric_name,metric_count1))
                metrics7 = cur.fetchall()
               cur.execute("select value from metrics where metric= (?) order by value asc limit 1 offset (?)*99/100-1;",(metric_name,metric_count1))
                metrics8 = cur.fetchall()
                for metric2 in metrics2:
                                for metric3 in metrics3:
                                        for metric4 in metrics4:
                                                for metric5 in metrics5:
                                                        for metric6 in metrics6:
                                                                for metric7 in metrics7:
                                                                        for metric8 in metrics8:
                                                                                metric_99per = metric8[1]
                                                                        metric_98per = metric7[1]
                                                                metric_95per = metric6[1]
                                                        metric_80per = metric5[1]
                                                metric_75per = metric4[1]
                                        metric_66per = metric3[1]
                                metric_50per = metric2[1]
                #metric_name = metric1[0].replace("servers", "agg")
                #metric_count = metric1[1]
                #metric_min = metric1[2]
                #metric_max = metric1[3]
                #metric_avg = metric1[4]
                #metric_sum = metric1[5]
                print(metric_name+".count",metric_count,timestamp)
                print(metric_name+".min",metric_min,timestamp)
                print(metric_name+".max",metric_max,timestamp)
                print(metric_name+".average",metric_avg,timestamp)
                print(metric_name+".sum",metric_sum,timestamp)
                print(metric_name+".50percentile",metric_50per,timestamp)
                print(metric_name+".66percentile",metric_66per,timestamp)
                print(metric_name+".75percentile",metric_75per,timestamp)
                print(metric_name+".80percentile",metric_80per,timestamp)
                print(metric_name+".95percentile",metric_95per,timestamp)
                print(metric_name+".95percentile",metric_98per,timestamp)
                print(metric_name+".99percentile",metric_99per,timestamp)
                print("")
con.close()

