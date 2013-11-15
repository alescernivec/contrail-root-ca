#!/bin/bash

OUTDIR="/etc/tomcat6"
SERVICES="contrail-ca-server contrail-oauth-as contrail-federation-api contrail-federation-web oauth-java-client-demo"

for SERVICE in $SERVICES
do
	echo "Creating private key and CSR"
	openssl req -newkey rsa:2048 -keyout ${OUTDIR}/$SERVICE.key -nodes -out ${OUTDIR}/$SERVICE.csr -subj /O=XLAB/OU=Research/CN=$SERVICE
	echo "Creating certificate"
	openssl ca -config CARoot/ca.conf -in ${OUTDIR}/$SERVICE.csr -out ${OUTDIR}/$SERVICE.crt -keyfile /var/lib/contrail/ca-server/rootca-key.pem -cert /var/lib/contrail/ca-server/rootca-cert.pem -verbose -batch
	echo "Creating PKCS12 files"
	openssl pkcs12 -export -in ${OUTDIR}/$SERVICE.crt -inkey ${OUTDIR}/$SERVICE.key -out ${OUTDIR}/$SERVICE.pkcs12 -name "$SERVICE" -password pass:contrail
	echo "Creating JKS file for the services"
	keytool -importkeystore -srckeystore ${OUTDIR}/$SERVICE.pkcs12 -srcstoretype pkcs12 -srcalias $SERVICE -destkeystore ${OUTDIR}/$SERVICE.jks -deststoretype jks -deststorepass contrail -destalias $SERVICE -srcstorepass contrail
done
