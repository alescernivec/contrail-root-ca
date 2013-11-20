#!/bin/bash

ROOTCA_SN="/DC=Slovenia/DC=XLAB/DC=Contrail/DC=ca"
DEMO_NAME="oauth-client-cred-flow-demo"
DEMO_LINK="http://bamboo.ow2.org/artifact/CONTRAIL-TRUNK/JOB1/build-latestSuccessful/Packages/common/oauth/oauth-java-client-demo/client-cred-flow/target/contrail-${DEMO_NAME}.tar.gz"

EXPECTED_ARGS=1
E_BADARGS=65

print_help() {
  echo ""
  echo "Usage: `basename $0` [OPTION]"
  echo "	OPTION can be 'test' or 'notest'"
  echo "	       test - installs oauth-java-client-demo"
 
}


if [ $# -ne $EXPECTED_ARGS ]
then
	print_help
	exit 0
fi

CONFIG=$1

if [ ${CONFIG} == "notest" ]
then
	echo "Installing ConSec on localhost"
	apt-get install contrail-ca-server contrail-federation-api contrail-oauth-as contrail-security-commons
	create-rootca-files ${ROOTCA_SN}
	cd bin
	./create_ca.sh
	./create_service_certs.sh
	./patch-files.sh
	cd ..
	service tomcat6 restart
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
