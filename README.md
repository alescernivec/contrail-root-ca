contrail-root-ca
================

The purpose of this package is to help bootstrapping the federation security services provided by Contrail packages. 
The main problem of the packages is setting up necessary details like service certificates, initial proerties etc.
Scripts provided by this package install CA Server, OAuth AS Server, Federation API and DEMO java program that tests
all these services with simple scenario: gets OAuth token from the AS and queries CA Server for delegated certificate
with the OAuth token provided. We will update this package with additional services like Federation Web and IdP soon.

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
# ./patch-files.sh
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
Patch the oauth-java-client-demo:
```
$ cd /path/to/cloned-git/contrail-root-ca/pathces
$ cp oauth-java-client-demo.diff /etc/contrail/oauth-java-client-demo/ && cd /etc/contrail/oauth-java-client-demo/
$ patch -p0 < oauth-java-client-demo.diff
```

Now, navigate back to the checked out dir with oauth-java-client-demo maven project.

Ask for an oauth2 token for user  contrailuser :
```
$ mvn exec:java -Dexec.mainClass="org.ow2.contrail.common.oauth.demo.ClientCredentialsFlowDemo" -Dexec.args="getToken caa6e102-8ff0-400f-a120-23149326a936"
```

If you get an error, something is missconfigured.

You should get something similar to:
```
Requesting OAuth access token from the Authorisation Server https://contrail-oauth-as:8443/oauth-as/r/access_token/request on behalf of the user caa6e102-8ff0-400f-a120-23149326a936.
Received access token: 965ec95f-9d51-3561-945f-ed9ad831663c
```

Now, get the cert:
```
mvn exec:java -Dexec.mainClass="org.ow2.contrail.common.oauth.demo.ClientCredentialsFlowDemo" -Dexec.args="getCert 965ec95f-9d51-3561-945f-ed9ad831663c"
```
Of course, change the token UUID with the one obtained in the step before.

You should get the delegated certificate indicating everything works!

Troubleshooting
----------

```
keytool -list -keystore /etc/tomcat6/cacerts.jks
```

This should return 5 entries

```
root@ubuntu:~/contrail-root-ca# keytool -list -keystore /etc/tomcat6/cacerts.jks 
Enter keystore password:  

Keystore type: JKS
Keystore provider: SUN

Your keystore contains 5 entries

contrail-ca-server, Nov 15, 2013, trustedCertEntry,
Certificate fingerprint (MD5): 8A:A6:D8:80:A1:E5:B3:01:94:0A:B4:65:3A:41:45:5E
contrail-federation-web, Nov 15, 2013, trustedCertEntry,
Certificate fingerprint (MD5): A0:A3:BF:58:3D:26:2C:F3:82:ED:90:02:ED:AE:B5:05
contrail-federation-api, Nov 15, 2013, trustedCertEntry,
Certificate fingerprint (MD5): 1C:24:DD:39:06:93:85:CB:AE:68:9E:A8:DF:FE:32:20
oauth-java-client-demo, Nov 15, 2013, trustedCertEntry,
Certificate fingerprint (MD5): B6:67:99:6D:B0:5F:7F:EB:B2:CD:73:45:5B:CC:11:4F
contrail-oauth-as, Nov 15, 2013, trustedCertEntry,
Certificate fingerprint (MD5): 65:F7:CE:46:C7:DD:86:08:0B:15:8F:F5:D1:80:18:0E
```

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
