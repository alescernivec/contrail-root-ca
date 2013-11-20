#! /bin/bash
CWD=`pwd`
CWD2="$CWD/../patches"
cd ${CWD2}
cp tomcat-server-mods.diff /etc/tomcat6/ && cd /etc/tomcat6/ && patch -p0 < tomcat-server-mods.diff 
cd ${CWD2}
cp hosts-mods.diff /etc/ && cd /etc/ && patch -p0 < hosts-mods.diff
cd ${CWD2}
cp ca-server-mods.diff /var/lib/tomcat6/webapps/ca/WEB-INF/ && cd /var/lib/tomcat6/webapps/ca/WEB-INF/ && patch -p0 < ca-server-mods.diff
cd ${CWD2}
cp contrail-federation-web-ssl-mods.diff /etc/apache2/sites-available/ && cd /etc/apache2/sites-available/ patch -p0 < contrail-federation-web-ssl-mods.diff
cd ${CWD2}
cp wildcard-simplesaml-ssl-mods.diff /etc/apache2/sites-available/ && cd /etc/apache2/sites-available/ && patch -p0 < wildcard-simplesaml-ssl-mods.diff
cd ${CWD2}
cp federation-web-conf-mods.diff /etc/contrail/contrail-federation-web/ && cd /etc/contrail/contrail-federation-web/ && patch -p0 < federation-web-conf-mods.diff
cd ${CWD2}
cp saml20-sp-remote.php-mods.diff /usr/share/simplesamlphp-1.9.0/metadata/ && cd /usr/share/simplesamlphp-1.9.0/metadata/ && patch -p0 < saml20-sp-remote.php-mods.diff
cd ${CWD2}
cp saml20-idp-hosted.php-mods.diff /usr/share/simplesamlphp-1.9.0/metadata/ && cd /usr/share/simplesamlphp-1.9.0/metadata/ && patch -p0 < saml20-idp-hosted.php-mods.diff
cd ${CWD2}
cd $CWD 
