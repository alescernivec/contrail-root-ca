#!/bin/bash

OUTDIR="/etc/tomcat6"
SERVICES="contrail-ca-server contrail-oauth-as contrail-federation-api contrail-federation-web oauth-java-client-demo"

openssl x509 -outform der -in /var/lib/contrail/ca-server/rootca-cert.pem -out ${OUTDIR}/root-ca.der

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
	echo "Adding ${SERVICE}'s cert to truststore"
	openssl x509 -outform der -in ${OUTDIR}/$SERVICE.crt -out ${OUTDIR}/$SERVICE.der
	keytool -import -alias ${SERVICE} -deststorepass contrail -srcstorepass contrail -keystore ${OUTDIR}/cacerts.jks -file ${OUTDIR}/${SERVICE}.der -noprompt
done
echo "Adding ROOT CA's cert to the truststore"
keytool -import -alias rootCa -deststorepass contrail -srcstorepass contrail -keystore ${OUTDIR}/cacerts.jks -file /var/lib/contrail/ca-server/rootca-cert.pem -noprompt
