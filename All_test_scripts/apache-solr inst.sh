#!/bin/bash
#script to install and check Apache solr 4.9.0
solr_inst()
{
pushd /tmp > /dev/null
echo webversafs | sudo -S wget /tmp/ http://apache.mirrors.tds.net/lucene/solr/4.9.0/solr-4.9.0.tgz
echo webversafs | sudo -S tar -xzf solr-4.9.0.tgz
echo webversafs | sudo -S mv solr-4.9.0/example /opt/solr
echo webversafs | sudo -S curl -o /etc/init.d/solr http://dev.eclipse.org/svnroot/rt/org.eclipse.jetty/jetty/trunk/jetty-distribution/src/main/resources/bin/jetty.sh
echo webversafs | sudo -S chmod +x /etc/init.d/solr
echo webversafs | sudo -S perl -pi -e 's/\/default\/jetty/\/sysconfig\/solr/g' /etc/init.d/solr
echo webversafs | sudo -S chkconfig solr on
echo webversafs | sudo -S useradd -r -d /opt/solr -M -c "Apache Solr" solr &> /dev/null
echo webversafs | sudo -S chown -R solr:solr /opt/solr/
echo webversafs | sudo -S echo "JAVA_HOME=/usr/java/default " >/tmp/tmp_solr
echo webversafs | sudo -S echo "JAVA_OPTIONS="-Dsolr.solr.home=/opt/solr/solr $JAVA_OPTIONS"">>/tmp/tmp_solr
echo webversafs | sudo -S echo "JETTY_HOME=/opt/solr">>/tmp/tmp_solr
echo webversafs | sudo -S echo "JETTY_USER=solr">>/tmp/tmp_solr
echo webversafs | sudo -S echo "JETTY_LOGS=/opt/solr/logs">>/tmp/tmp_solr
echo webversafs | sudo -S mv /tmp/tmp_solr /etc/sysconfig/solr
echo webversafs | sudo -S /etc/init.d/solr start
if (( $? == 0 )); then
clear
echo "Apache Solr is installed ; Manually checking"
clear
sudo netstat -tnlp | grep :8983
echo "Press Y if Port is Open or N if Not"
read opt
else
echo "Apache -solr is not configures properly"
echo "Check the error"
echo webversafs | sudo -S /etc/init.d/solr start
fi
}


java -version &> /dev/null ;  if (( `echo $?` == 0 )) ; then
solr_inst
else
echo "Java is not installed ... Installing it"
echo webversafs | sudo -S yum -y install java-1.7.0-openjdk.x86_64
echo "Installig Apache solr 4.9.0......"
solr_inst
fi

