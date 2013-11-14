#!/bin/bash

SERVICES="contrail-ca-server contrail-oauth-as contrail-federation-api contrail-federation-web oauth-java-client-demo"

for SERVICE in $SERVICES
do
	openssl req -newkey rsa:2048 -keyout $SERVICE.key -nodes -out $SERVICE.csr -subj /O=XLAB/OU=Research/CN=$SERVICE
	openssl ca -config CARoot/ca.conf -in $SERVICE.csr -out $SERVICE.crt -keyfile /var/lib/contrail/ca-server/rootca-key.pem -cert /var/lib/contrail/ca-server/rootca-cert.pem -verbose -batch
	openssl pkcs12 -export -in $SERVICE.crt -inkey $SERVICE.key -out $SERVICE.pkcs12 -name "$SERVICE" -password pass:contrail
	keytool -importkeystore -srckeystore $SERVICE.pkcs12 -srcstoretype pkcs12 -srcalias $SERVICE -destkeystore $SERVICE.jks -deststoretype jks -deststorepass contrail -destalias $SERVICE -srcstorepass contrail
done
