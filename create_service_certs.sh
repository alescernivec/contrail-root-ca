#!/bin/bash

OUTDIR="/etc/tomcat6"
SERVICES="contrail-ca-server contrail-oauth-as contrail-federation-api contrail-federation-web oauth-java-client-demo"

for SERVICE in $SERVICES
do
	openssl req -newkey rsa:2048 -keyout ${OUTDIR}/$SERVICE.key -nodes -out ${OUTDIR}/$SERVICE.csr -subj /O=XLAB/OU=Research/CN=$SERVICE
	openssl ca -config CARoot/ca.conf -in ${OUTDIR}/$SERVICE.csr -out ${OUTDIR}/$SERVICE.crt -keyfile /var/lib/contrail/ca-server/rootca-key.pem -cert /var/lib/contrail/ca-server/rootca-cert.pem -verbose -batch
	openssl pkcs12 -export -in ${OUTDIR}/$SERVICE.crt -inkey ${OUTDIR}/$SERVICE.key -out ${OUTDIR}/$SERVICE.pkcs12 -name "$SERVICE" -password pass:contrail
	keytool -importkeystore -srckeystore ${OUTDIR}/$SERVICE.pkcs12 -srcstoretype pkcs12 -srcalias $SERVICE -destkeystore ${OUTDIR}/$SERVICE.jks -deststoretype jks -deststorepass contrail -destalias $SERVICE -srcstorepass contrail
done
