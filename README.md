contrail-root-ca
================

Demonstrates how to create everything you need for signing e.g. host certificates by using exising CA cert and key files.

First, generate what you need for the CA to work. Navigate to some empty directory and issue:
```
./create_ca.sh
```

Example follows on how to sign the CSR. **in** takes path to the server's CSR, **out** takes output to the new cervers cert (signed one). **keyfile** points to root CA's key, **cert** points to the root CA's certificate.
```
openssl ca -config CARoot/ca.conf -in ../ca-server-csr.pem -out ../ca-server-cert.pem -keyfile /var/lib/contrail/ca-server/rootca-key.pem -cert /var/lib/contrail/ca-server/rootca-cert.pem -verbose -batch
```

An example on how to check the newly generated cert:
```
openssl x509 -text -in ../ca-server-cert.pem -noout
```

Example how to revoke some cert:
```
openssl ca -revoke ./CARoot/ca.db.certs/01.pem -config CARoot/ca.conf -keyfile /var/lib/contrail/ca-server/rootca-key.pem -cert /var/lib/contrail/ca-server/rootca-cert.pem -verbose
```

And just for fun, example how to generate **pkcs12** file:
```
 openssl pkcs12 -export -in ca-server-cert.pem -inkey ca-server-key.pem -CAfile /tmp/all-ca-certs.pem -out /var/lib/contrail/ca-server/ks.p12 -caname root -chain
```

To sum up
----
Basic contrail security services consist of:

* contrail-ca-server Contrail CA Server
* contrail-federation-api Contrail Federation API
* contrail-federation-db Contrail Federation Database
* contrail-oauth-as Contrail Oauth AS
* contrail-security-commons Contrail Security Commons

Create host certificates:
* contrail-ca-server
* contrail-oauth-as
* contrail-federation-api
* contrail-federation-web

BATCH JOB:
----------
```
create-rootca-files /DC=Slovenia/DC=Contrail/DC=ca
```
```
./create_ca.sh
```

Root CA to DER:
```
openssl x509 -outform der -in /var/lib/contrail/ca-server/rootca-cert.pem -out rootca-cert.der
keytool -import -alias rootca-cert -keystore cacerts.jks -file rootca-cert.der -deststorepass contrail
```

FOR EACH SERVICE:
----------
```
openssl req -newkey rsa:2048 -keyout $SERVICE.key -nodes -out $SERVICE.csr -subj /O=XLAB/OU=Research/CN=$SERVICE
openssl ca -config CARoot/ca.conf -in $SERVICE.csr -out $SERVICE.crt -keyfile /var/lib/contrail/ca-server/rootca-key.pem -cert /var/lib/contrail/ca-server/rootca-cert.pem -verbose -batch
openssl pkcs12 -export -in $SERVICE.crt -inkey $SERVICE.key -out $SERVICE.pkcs12 -name "$SERVICE" -password pass:contrail
keytool -importkeystore -srckeystore $SERVICE.pkcs12 -srcstoretype pkcs12 -srcalias $SERVICE -destkeystore $SERVICE.jks -deststoretype jks -deststorepass contrail -destalias $SERVICE -srcstorepass contrail
```
