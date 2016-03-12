#!/bin/bash
#script to download and install nexus over instances
cd /home/vlg/
wget http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz
mkdir nexus
tar -xvf  nexus-latest-bundle.tar.gz -C nexus
./nexus/bin/nexus start
