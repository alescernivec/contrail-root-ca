contrail-root-ca
================

The purpose of this package is to help bootstrapping the federation security services provided by Contrail packages. 
The main problem of the packages is setting up necessary details like service certificates, initial service properties etc.
Scripts provided by this package install CA Server, OAuth AS Server, Federation API and DEMO java program that tests
all these services with simple scenario: gets OAuth token from the AS and queries CA Server for delegated certificate
with the OAuth token provided. These scripts asume that we install the packages on clean Ubuntu 12.04 server. We will update this package with additional services like Federation Web and IdP soon.

Usage
---------
This will set up contrail testing repository - latest testing packages from Contrail:
```
# echo "deb http://contrail.ow2.org/repositories/binaries/testing/xUbuntu_12.04/ ./" >> /etc/apt/sources.list
# wget -O - http://contrail.ow2.org/repositories/contrail.pub | sudo apt-key add -
# apt-get update
```
Alternative repository is (in case you have problems with the ow2.org.
```
http://download.opensuse.org/repositories/home:/contrail:/testing/xUbuntu_12.04/
```

This installs basic security packages and configures the key, certificates and service packages. 
```
# ./install notest
```
Testing
----------

How to test installed components? You should first install basic sec packages with "notest". After that, issue
```
# ./install test
```

Now, navigate back to the checked out dir with oauth-java-client-demo maven project.

Ask for an oauth2 token for user  contrailuser :
```
$ /usr/share/contrail/oauth-java-client/demo/oauth-client-cred-flow-demo.sh getToken caa6e102-8ff0-400f-a120-23149326a936
```

If you get an error, something is missconfigured.

You should get something similar to:
```
Requesting OAuth access token from the Authorisation Server https://contrail-oauth-as:8443/oauth-as/r/access_token/request on behalf of the user caa6e102-8ff0-400f-a120-23149326a936.
Received access token: 965ec95f-9d51-3561-945f-ed9ad831663c
```

Now, get the cert:
```
$ /usr/share/contrail/oauth-java-client/demo/oauth-client-cred-flow-demo.sh getCert 965ec95f-9d51-3561-945f-ed9ad831663c
```
Of course, change the token UUID with the one obtained in the step before.

You should get the delegated certificate indicating everything works!

Details
----

Basic contrail security services consist of:

* contrail-ca-server Contrail CA Server
* contrail-federation-api Contrail Federation API
* contrail-federation-db Contrail Federation Database
* contrail-oauth-as Contrail Oauth AS
* contrail-security-commons Contrail Security Commons

List of services that are provided with the certificates:
* contrail-ca-server
* contrail-oauth-as
* contrail-federation-api
* contrail-federation-web

Troubleshooting
----------

```
keytool -list -keystore /etc/tomcat6/cacerts.jks
```

This should return 6 entries

```
root@ubuntu:~/oauth-java-client-demo# keytool -list -keystore /etc/tomcat6/cacerts.jks 
Enter keystore password:  

Keystore type: JKS
Keystore provider: SUN

Your keystore contains 6 entries

contrail-ca-server, Nov 18, 2013, trustedCertEntry,
Certificate fingerprint (MD5): B1:FB:22:9A:99:BA:3B:17:E0:CF:5A:C0:25:36:CA:04
rootca, Nov 18, 2013, trustedCertEntry,
Certificate fingerprint (MD5): 66:F7:3C:4A:33:4C:7D:FE:5D:86:2D:18:2E:79:B8:07
contrail-federation-web, Nov 18, 2013, trustedCertEntry,
Certificate fingerprint (MD5): 52:2C:C9:75:4C:CA:6F:18:72:F9:B9:48:DD:A5:DB:FA
contrail-federation-api, Nov 18, 2013, trustedCertEntry,
Certificate fingerprint (MD5): F0:69:67:92:25:75:CD:44:48:8E:AF:1D:B3:AD:72:34
oauth-java-client-demo, Nov 18, 2013, trustedCertEntry,
Certificate fingerprint (MD5): 92:06:3D:3C:A9:EB:D5:33:8A:96:C7:5F:34:18:88:F3
contrail-oauth-as, Nov 18, 2013, trustedCertEntry,
Certificate fingerprint (MD5): C9:92:87:FE:05:C1:F9:AB:FA:A7:33:39:79:7E:C3:6F
```

List of certificates and locations (for each service):
----------

```
/etc/tomcat6/cacerts.jks
/etc/tomcat6/$SERVICE/$SERVICE.jks
/etc/tomcat6/$SERVICE/$SERVICE.pkcs12
```

Internal CA usage
----------
You do not need to read this if you do not care about the details on how the keys and certs are generated.

Demonstrates how to create everything you need for signing e.g. host certificates by using exising CA cert and key files.

First, generate what you need for the CA to work. Navigate to some empty directory and issue:
```
./bin/create_ca.sh
```
This creates all neccessary keys, certs, keystores, truststores:
```
./bin/create_service_certs.sh
```
To clean up:
```
./bin/clean.sh
```

More details
----------

You do not need to read this if you do not care about the details on how the keys and certs are generated.

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
