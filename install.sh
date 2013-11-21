#!/bin/bash

# SN of the Root CA Certificat. This is an argument for CA Server's create-root-ca call.
ROOTCA_SN="/DC=Slovenia/DC=XLAB/DC=Contrail/DC=ca"

# Name od the demo oauth package (when testing the service)
DEMO_NAME="oauth-client-cred-flow-demo"

# Where the demo OAuth package resides.
DEMO_LINK="http://bamboo.ow2.org/artifact/CONTRAIL-TRUNK/JOB1/build-latestSuccessful/Packages/common/oauth/oauth-java-client-demo/client-cred-flow/target/contrail-${DEMO_NAME}.tar.gz"

# Other dependencies
DEPS="curl wget"

# Contrail services
SERVICES="contrail-security-commons contrail-ca-server contrail-oauth-as contrail-federation-api contrail-federation-web contrail-federation-id-prov-support"

# Exit on error
set -e

# Set non interactive
export DEBIAN_FRONTEND="noninteractive"

EXPECTED_ARGS=1
E_BADARGS=65

print_help() {
  echo ""
  echo "Usage: `basename $0` [OPTION]"
  echo "	OPTION can be 'test' or 'notest'"
  echo "	       test - installs oauth-java-client-demo"
 
}

# Updates certificates of the IdP
update_certs_idp(){
	cp -fs /etc/tomcat6/contrail-federation-id-prov-support/contrail-federation-id-prov-support.crt /usr/share/simplesamlphp-1.9.0/cert/wildcard-contrail-idp.cert
	cp -fs /etc/tomcat6/contrail-federation-id-prov-support/contrail-federation-id-prov-support.key /usr/share/simplesamlphp-1.9.0/cert/wildcard-contrail-idp.key
	cp -fs /etc/tomcat6/contrail-federation-id-prov-support/contrail-federation-id-prov-support.crt /usr/share/simplesamlphp-1.9.0/cert/server.crt
	cp -fs /etc/tomcat6/contrail-federation-id-prov-support/contrail-federation-id-prov-support.key /usr/share/simplesamlphp-1.9.0/cert/server.pem
}

# Updates certificates of the Contrail Federation Web
update_certs_web(){
	cp -fs /etc/tomcat6/contrail-federation-web/contrail-federation-web.crt /usr/lib/contrail/federation-web/extra/contrail-federation-web.cert
	cp -fs /etc/tomcat6/contrail-federation-web/contrail-federation-web.key /usr/lib/contrail/federation-web/extra/contrail-federation-web.key
	cp -fs /var/lib/contrail/ca-server/rootca-cert.pem /usr/lib/contrail/federation-web/extra/ca.crt
}

# Updates Web Configuration with SAML metadata
update_web_conf(){
	METADATA=`curl --insecure https://contrail-federation-id-prov-support/simplesaml/saml2/idp/metadata.php` 
	echo -e "<?xml version=\"1.0\"?>\n<md:EntitiesDescriptor xmlns:md=\"urn:oasis:names:tc:SAML:2.0:metadata\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\">${METADATA}\n</md:EntitiesDescriptor>" > /usr/lib/contrail/federation-web/extra/remote_metadata.xml
}

update_oauth_conf(){
	METADATA=`curl --insecure https://contrail-federation-id-prov-support/simplesaml/saml2/idp/metadata.php`; 
	echo $METADATA > temp; 
	exec ./bin/print_xml.py temp | tail -n +2 > toadd
	cat /etc/contrail/contrail-oauth-as/saml-metadata.xml toadd > saml-metadata.xml-temp
	mv saml-metadata.xml-temp /etc/contrail/contrail-oauth-as/saml-metadata.xml
	rm toadd; rm temp; 
	echo "</EntitiesDescriptor>" >> /etc/contrail/contrail-oauth-as/saml-metadata.xml
}

if [ $# -ne $EXPECTED_ARGS ]
then
	print_help
	exit 0
fi

CONFIG=$1

if [ ${CONFIG} == "notest" ]
then
	echo "Installing ConSeC on localhost"
	apt-get install ${SERVICES} ${DEPS}
	create-rootca-files ${ROOTCA_SN}
	cd bin
	./create_ca.sh
	./create_service_certs.sh
	./patch-files.sh
	cd ..
	echo "Updating certificates for contrail-idp"
	update_certs_idp
	echo "Updating certificates for contrail-federation-web"
	update_certs_web
	service tomcat6 restart
        service apache2 reload
	echo "Sleeping for 20s (tomcat needs to bootstrap)..."
	sleep 20
	echo "...done"
	update_web_conf
	update_oauth_conf
	service tomcat6 restart
	service apache2 reload
	exit 0
elif [ ${CONFIG} == "test" ]
then
	wget ${DEMO_LINK}
	tar xvfz contrail-${DEMO_NAME}.tar.gz
	mkdir -p /usr/share/contrail/${DEMO_NAME}/lib
	mkdir -p /etc/contrail/${DEMO_NAME}/
	cd contrail-${DEMO_NAME}
	cp -r etc/* /etc/
	cp -r usr/* /usr/
	cd ..
	cd patches
	cp oauth-java-client-demo.diff /etc/contrail/${DEMO_NAME}/
	cd /etc/contrail/${DEMO_NAME}/
	patch -p0 < oauth-java-client-demo.diff
	cd -
	cd ..
	exit 0
fi
echo "Unknown parameter"
print_help
exit 1
