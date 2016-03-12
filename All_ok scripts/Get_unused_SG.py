import boto
import boto.ec2
import sys
import subprocess
account=['vid', 'lmn']
for acc in account:
                if acc == "vid":
                        AK="AKIAIFVGUARTUV6HPHTQ"
                        SAK="2nYqGL7ehSMkugZX3gl/TtMofQ+PzKKHhTE/uynE"
						f = open('/home/akohale/arpit/unused_SG/vid', 'w')
						sys.stdout = f
                else:
                        AK="AKIAJGCNJXKN7NPIQSOQ"
                        SAK="n/QbNZpu8kwnP98u8PjYHX8rCEjsDl/BYcPk6Fa5"
						f=open('/home/akohale/arpit/unused_SG/lmn', 'w')
						sys.stdout = f
                REGION=['eu-west-1','sa-east-1','us-east-1','ap-northeast-1','us-west-1','us-west-2','ap-southeast-1','ap-southeast-2']
                for EC2_REGION in REGION:
                        ec2region = boto.ec2.get_region(EC2_REGION)
                        ec2 = boto.connect_ec2(region=ec2region, aws_access_key_id=AK, aws_secret_access_key=SAK)
                        sgs = ec2.get_all_security_groups()
                        print "========== %s-REGION=%s=========" % (acc, EC2_REGION)
                        for sg in sgs:
                                if len(sg.instances()) == 0:
                                        print ("{0}\t{1}\t{2} instances".format(sg.id, sg.name, len(sg.instances())))
                                        
def send_message(recipient, subject, body):
    process = subprocess.Popen(['mail', '-s', subject, '-a', '/home/akohale/arpit/unused_SG/lmn', '-a', '/home/akohale/arpit/unused_SG/vid', recipient],stdin=subprocess.PIPE)
    process.communicate(body)

send_message ('akohale@videologygroup.com', 'Test_mail', 'Hello')