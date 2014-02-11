#! /bin/bash
CWD=`pwd`
CWD2="$CWD/../patches"
cd ${CWD2}
echo "Patching Tomcat's server.xml"
cp tomcat-server-mods.diff /etc/tomcat6/ && cd /etc/tomcat6/ && patch -p0 < tomcat-server-mods.diff 
cd ${CWD2}
echo "Patching hosts file"
#cp hosts-mods.diff /etc/ && cd /etc/ && patch -p0 < hosts-mods.diff
./patch-hosts.sh
cd ${CWD2}
echo "Patching CA Server"
cp ca-server-mods.diff /var/lib/tomcat6/webapps/ca/WEB-INF/ && cd /var/lib/tomcat6/webapps/ca/WEB-INF/ && patch -p0 < ca-server-mods.diff
cd ${CWD2}
echo "Patching Apache2 sites"
cp contrail-federation-web-ssl-mods.diff /etc/apache2/sites-available/ && cd /etc/apache2/sites-available/ && patch -p0 < contrail-federation-web-ssl-mods.diff
cd ${CWD2}
cp wildcard-simplesaml-ssl-mods.diff /etc/apache2/sites-available/ && cd /etc/apache2/sites-available/ && patch -p0 < wildcard-simplesaml-ssl-mods.diff
cd ${CWD2}
echo "Patching Federation Web"
cp federation-web-conf-mods.diff /etc/contrail/contrail-federation-web/ && cd /etc/contrail/contrail-federation-web/ && patch -p0 < federation-web-conf-mods.diff
cd ${CWD2}
echo "Patching SimpleSAMLphp"
cp saml20-sp-remote.php-mods.diff /usr/share/simplesamlphp-1.9.0/metadata/ && cd /usr/share/simplesamlphp-1.9.0/metadata/ && patch -p0 < saml20-sp-remote.php-mods.diff
cd ${CWD2}
cp saml20-idp-hosted.php-mods.diff /usr/share/simplesamlphp-1.9.0/metadata/ && cd /usr/share/simplesamlphp-1.9.0/metadata/ && patch -p0 < saml20-idp-hosted.php-mods.diff
cd ${CWD2}
echo "Patching OAuth AS"
cp saml-metadata.xml-mods.diff /etc/contrail/contrail-oauth-as && cd /etc/contrail/contrail-oauth-as/ && patch -p0 < saml-metadata.xml-mods.diff
cd ${CWD2}
cp oauth-as-mods.diff /etc/contrail/contrail-oauth-as && cd /etc/contrail/contrail-oauth-as/ && patch -p0 < oauth-as-mods.diff
cd ${CWD2}
cp oauth-as-web-xml-mods.diff /var/lib/tomcat6/webapps/oauth-as/WEB-INF && cd /var/lib/tomcat6/webapps/oauth-as/WEB-INF && patch -p0 < oauth-as-web-xml-mods.diff
cd ${CWD2}
mysql -u contrail -pcontrail contrail_oauth_as -e "update client set callback_uri=\"https://contrail-federation-web/oauth2callback\" where client_id=\"oauth-python-client-demo\";" 
cd $CWD 
