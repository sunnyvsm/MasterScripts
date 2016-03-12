#!/usr/bin/python26

import argparse

import urllib2

import simplejson

import base64

 

parser = argparse.ArgumentParser(description='check couchbase bucket cache miss ratio')

parser.add_argument('-n','--node', help='couchbase node', required=True)

parser.add_argument('-b','--bucket', help='couchbase bucket', required=True)

parser.add_argument('-u','--username', help='couchbase username', required=True)

parser.add_argument('-p','--password', help='couchbase password', required=True)

parser.add_argument('-w','--warning', help='warning threshold', required=True)

parser.add_argument('-c','--critical', help='critical threshold', required=True)

args = vars(parser.parse_args())

 

node = args['node']

bucket = args['bucket']

username = args['username']

password = args['password']

warning = args['warning']

critical = args['critical']

 

bucket_json = "http://" + node + ":8091" + "/pools/default/buckets/" + bucket + "/stats?zoom=hour"

base64string = base64.encodestring('%s:%s' % (username, password)).replace('\n', '')

request = urllib2.Request(bucket_json)

request.add_header("Authorization", "Basic %s" % base64string)

response = urllib2.urlopen(request)

json=simplejson.load(response)

 

cmd_get = json["op"]["samples"]["cmd_get"];

sum_cmd_get = sum(cmd_get);

 

ep_bg_fetched = json["op"]["samples"]["ep_bg_fetched"];

sum_ep_bg_fetched = sum(ep_bg_fetched);

 

if sum_cmd_get == 0 or sum_ep_bg_fetched == 0:

        cache_miss_ratio = 0

else:

        cache_miss_ratio = (sum_ep_bg_fetched/sum_cmd_get);

        cache_miss_ratio = (cache_miss_ratio * 100);

 

print "cache miss ratio:" , cache_miss_ratio;

 

warning = float(warning);

critical = float(critical);

if cache_miss_ratio >= critical:

        exit(2)

 

if cache_miss_ratio >= warning:

        exit(1)

 

exit(0)