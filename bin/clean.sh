#!/bin/bash

OUTDIR="/etc/tomcat6"
SERVICES="contrail-ca-server contrail-oauth-as contrail-federation-api contrail-federation-web oauth-java-client-demo contrail-federation-id-prov-support"

rm -fr CARoot/

for SERVICE in $SERVICES
do
	rm -fr ${OUTDIR}/${SERVICE}
done

rm -fr ${OUTDIR}/cacerts.jks
rm -fr ${OUTDIR}/root-ca.der
