#!/bin/bash
CAROOT=CARoot
CAKEY=/var/lib/contrail/ca-server/rootca-key.pem
CACERT=/var/lib/contrail/ca-server/rootca-cert.pem

mkdir -p ${CAROOT}/ca.db.certs   # Signed certificates storage
touch ${CAROOT}/ca.db.index      # Index of signed certificates
echo 01 > ${CAROOT}/ca.db.serial # Next (sequential) serial number

# Configuration
cat>${CAROOT}/ca.conf<<'EOF'
[ ca ]
default_ca = ca_default

[ ca_default ]
dir = REPLACE_LATER
certs = $dir
new_certs_dir = $dir/ca.db.certs
database = $dir/ca.db.index
serial = $dir/ca.db.serial
RANDFILE = $dir/ca.db.rand
certificate = CACERT_LATER
private_key = CAKEY_LATER
default_days = 3650
default_crl_days = 30
default_md = md5
preserve = no
policy = generic_policy
[ generic_policy ]
countryName = optional
stateOrProvinceName = optional
localityName = optional
organizationName = optional
organizationalUnitName = optional
commonName = supplied
emailAddress = optional
EOF

sed -i "s|REPLACE_LATER|${CAROOT}|" ${CAROOT}/ca.conf
sed -i "s|CAKEY_LATER|${CAKEY}|" ${CAROOT}/ca.conf
sed -i "s|CACERT_LATER|${CACERT}|" ${CAROOT}/ca.conf

cd ${CAROOT}
