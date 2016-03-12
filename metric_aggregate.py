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
cur.execute('select distinct metric, count(metric),min(value),max(value),avg(value),sum(value) from metrics group by metric;')
metrics = cur.fetchall()
for metric in metrics:
  metric_name = metric[0].replace("servers", "agg")
  metric_count = metric[1]
  metric_min = metric[2]
  metric_max = metric[3]
  metric_avg = metric[4]
  metric_sum = metric[5]
  print(metric_name+".count",metric_count,timestamp)
  print(metric_name+".min",metric_min,timestamp)
  print(metric_name+".max",metric_max,timestamp)
  print(metric_name+".average",metric_avg,timestamp)
  print(metric_name+".sum",metric_sum,timestamp)



cur.execute("select distinct metric, value from metrics order by value asc limit (?) offset 2*99/100-1;",(metric_count,))
metrics = cur.fetchall()
for metric in metrics:
  metric_name = metric[0].replace("servers", "agg")
  metric_per = metric[1]
  print(metric_name+".95percentile",metric_per,timestamp)

cur.execute("select distinct metric, value from metrics order by value asc limit (?) offset 2*99/100-1;",(metric_count,))
metrics = cur.fetchall()
for metric in metrics:
  metric_name = metric[0].replace("servers", "agg")
  metric_per = metric[1]
  print(metric_name+".99percentile",metric_per,timestamp)
metrics = cur.fetchall()
con.close()
