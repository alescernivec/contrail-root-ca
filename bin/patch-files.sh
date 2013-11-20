#! /bin/bash

cd patches
CWD=`pwd`
cp tomcat-server-mods.diff /etc/tomcat6/ && cd /etc/tomcat6/ && patch -p0 < tomcat-server-mods.diff 
cd ${CWD}
cp hosts-mods.diff /etc/ && cd /etc/ && patch -p0 < hosts-mods.diff
cd ${CWD}
cp ca-server-mods.diff /var/lib/tomcat6/webapps/ca/WEB-INF/ && cd /var/lib/tomcat6/webapps/ca/WEB-INF/ && patch -p0 < ca-server-mods.diff
cd ${CWD}
cd ..
