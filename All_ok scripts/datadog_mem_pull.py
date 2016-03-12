import requests
import json
import csv

url = 'https://app.datadoghq.com/api/v1/query'
param = {'api_key' : '6dd4390b922f60d687d59bfe1541ae68', 'application_key' : '5a2d2a75f143be3dacdb84f1bff1198291cfd365' , 'from' : '1449792000'  , 'to' : '1450310400' , 'query' : 'avg:system.mem.used{*}by{host}'}
resp = requests.get(url=url, params=param)

print (resp.url)

data = json.loads(resp.text)
print data

c =csv.writer(open("MYFILE.csv", "wb"))
#c.writerow([host,average_memory,peak_memory ])
for val in data["series"]:
 totalmem=0
 counter=0
 for mem in val["pointlist"]:
  if type(mem[1]) == float :  totalmem = totalmem + mem[1]; counter = counter +1
  if counter == 0:
        avg_mem="Data_Missing"
  else :
        avg_mem = totalmem/counter;
 max_mem = max ([ mem[1] for mem in val["pointlist"] if type(mem[1]) == float ])
 c.writerow([ val["scope"] , avg_mem , max_mem ])
 print " %s |  %s " % (val["scope"] , totalmem/counter)
