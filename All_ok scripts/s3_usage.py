#Python script to calculate the s3 bucket usage
from boto.s3.connection import S3Connection
s3bucket = S3Connection('<Access-key>', '<Secret-Access-Key>').get_bucket('<bucket Name>')
size = 0
for key in s3bucket.list():
size += key.size
print "%.3f GB" % (size*1.0/1024/1024/1024)
