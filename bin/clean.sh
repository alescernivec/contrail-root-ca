#!/bin/bash

OUTDIR="/etc/tomcat6"
SERVICES="contrail-ca-server contrail-oauth-as contrail-federation-api contrail-federation-web oauth-java-client-demo"

rm -fr CARoot/

for SERVICE in $SERVICES
do
	rm -fr ${OUTDIR}/${SERVICE}.jks
	rm -fr ${OUTDIR}/${SERVICE}.csr
	rm -fr ${OUTDIR}/${SERVICE}.crt
	rm -fr ${OUTDIR}/${SERVICE}.key
	rm -fr ${OUTDIR}/${SERVICE}.pkcs12
	rm -fr ${OUTDIR}/${SERVICE}.der
done

rm -fr ${OUTDIR}/cacerts.jks
