contrail-root-ca
================

Details
----
Dependencies:
* contrail-federation

Basic contrail security services consist of:

* contrail-ca-server Contrail CA Server
* contrail-federation-api Contrail Federation API
* contrail-federation-db Contrail Federation Database
* contrail-oauth-as Contrail Oauth AS
* contrail-security-commons Contrail Security Commons

List of services that are provided with the certificates ($SERVICE):
* contrail-ca-server
* contrail-oauth-as
* contrail-federation-api
* contrail-federation-web
* oauth-java-client-demo

Usage
---------

```
# echo "deb http://contrail.ow2.org/repositories/binaries/testing/xUbuntu_12.04/ ./" >> /etc/apt/sources.list
# wget -O - http://contrail.ow2.org/repositories/contrail.pub | sudo apt-key add -
# apt-get update
# apt-get install contrail-ca-server contrail-federation-api contrail-oauth-as contrail-security-commons
# create-rootca-files /DC=Slovenia/DC=XLAB/DC=Contrail/DC=ca
# ./create_ca.sh
# ./create_service_certs.sh
```
Now, edit basic tomcat connectors (under /etc/tomcat6/services.xml):

```
<!-- CA Server - user cert -->
<Connector port="8081" protocol="HTTP/1.1" SSLEnabled="true"
keystoreType="PKCS12" keystorePass="contrail" 
keystoreFile="/etc/tomcat6/contrail-ca-server.pkcs12"
maxThreads="150" scheme="https" secure="true"
clientAuth="false" sslProtocol="TLS"
/>

<!-- OAuth AS Server -->
<Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true"
   maxThreads="150" scheme="https" secure="true"
   clientAuth="want" sslProtocol="TLS"
   keystoreFile="/etc/tomcat6/contrail-oauth-as.jks" keystorePass="contrail"
   truststoreFile="/etc/tomcat6/ccacerts.jks" truststorePass="contrail"
   keyAlias="ocontrail-oauth-as"
   ciphers="SSL_RSA_WITH_RC4_128_SHA" />

<!-- CA Server - delegated user certs -->
<Connector port="8444" protocol="HTTP/1.1" 
SSLEnabled="true" keystoreType="PKCS12" 
keystorePass="contrail" keystoreFile="/etc/tomcat6/contrail-ca-server.pkcs12" 
maxThreads="150" scheme="https" secure="true" clientAuth="want" 
sslProtocol="TLS" truststoreType="JKS" truststorePass="contrail" 
truststoreFile="/etc/tomcat6/cacerts.jks"/>
```

Testing
----------

How to test installed components?
```
# apt-get install maven openjdk-6-jdk subversion
```

Install contrail parent POM:
```
$ svn co svn://svn.forge.objectweb.org/svnroot/contrail/trunk/common/contrail-parent
$ cd contrail-parent
$ mvn install
$ cd ..
```

Checkout  oauth-java-client-demo :
```
$ svn co svn://svn.forge.objectweb.org/svnroot/contrail/trunk/common/oauth/oauth-java-client-demo/
$ mkdir -p /etc/contrail/oauth-java-client-demo/ && cd oauth-java-client-demo/ && cp ./src/main/conf/oauth-java-client-demo.properties /etc/contrail/oauth-java-client-demo/
$ mvn clean compile
```

Ask for an oauth2 token for user  contrailuser :
```
$ mvn exec:java -Dexec.mainClass="org.ow2.contrail.common.oauth.demo.ClientCredentialsFlowDemo" -Dexec.args="getToken caa6e102-8ff0-400f-a120-23149326a936"
```

If you get an error, something is missconfigured.

List of certificates and locations (for each service):
----------

```
/etc/tomcat6/cacerts.jks
/etc/tomcat6/$SERVICE.jks
/etc/tomcat6/$SERVICE.pkcs12
```

Internal CA usage
----------
Demonstrates how to create everything you need for signing e.g. host certificates by using exising CA cert and key files.

First, generate what you need for the CA to work. Navigate to some empty directory and issue:
```
./create_ca.sh
```
This creates all neccessary keys, certs, keystores, truststores:
```
create_service_certs.sh
```
To clean up:
```
./clean.sh
```

More details
----------

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
