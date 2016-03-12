# java
default['java']['jdk']['8']['x86_64']['url'] = "http://s3.amazonaws.com/videologypublic/repo/jdk-8u11-linux-x64.tar.gz"
default['java']['jdk']['8']['x86_64']['checksum'] = "f3593b248b64cc53bf191f45b92a1f10e8c5099c2f84bd5bd5d6465dfd07a8e9"

default['vlg-nexus']['packageNm'] = 'nexus-latest-bundle.tar.gz'
default['vlg-nexus']['httpd_conf']="/etc/httpd/conf.d"
default['packages'] = node['packages'] + [ 'httpd' ]
default['vlg-nexus']['nexus_home'] = '/home/vlg/nexus'
default['vlg-nexus']['public_ip']=`wget -qO- http://ipecho.net/plain`