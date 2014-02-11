cat <<EOF >> /etc/hosts
127.0.0.1 contrail-oauth-as
127.0.0.1 contrail-ca-server
127.0.0.1 oauth-java-client-demo
127.0.0.1 contrail-federation-id-prov-support
127.0.0.1 contrail-federation-web
127.0.0.1 contrail-federation-api
EOF
sed -i '/multi.contrail-idp.contrail.eu/d' /etc/hosts
sed -i '/contrail-federation-web.contrail.eu/d' /etc/hosts
sed -i '/contrail-idp.contrail.eu/d' /etc/hosts
