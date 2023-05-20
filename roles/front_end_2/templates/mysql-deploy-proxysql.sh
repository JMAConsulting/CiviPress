#!/bin/sh
domain={{hostvars[inventory_hostname]['preseed_hostname']}}.{{hostvars[inventory_hostname]['preseed_domain']}}
cert_dir=/var/lib/mysql
user=mysql.mysql
cp /etc/letsencrypt/live/$domain/privkey.pem $cert_dir/privkey.pem

openssl x509 -in /etc/letsencrypt/live/$domain/fullchain.pem > $cert_dir/fullchain.pem

wget https://curl.se/ca/cacert.pem -P /etc/letsencrypt/live/$domain/
cat /etc/letsencrypt/live/$domain/fullchain.pem >> /etc/letsencrypt/live/$domain/cacert.pem
cp /etc/letsencrypt/live/$domain/cacert.pem $cert_dir/cacert.pem

chown $user $cert_dir/*.pem
chmod 700 $cert_dir/*.pem

mysql --login-path=renew_tls_user@localhost --execute="ALTER INSTANCE RELOAD TLS" 

proxy_cert_dir=/var/lib/proxysql
user=proxysql.proxysql
cp /etc/letsencrypt/live/$domain/privkey.pem $proxy_cert_dir/privkey.pem

openssl x509 -in /etc/letsencrypt/live/$domain/fullchain.pem > $proxy_cert_dir/fullchain.pem

cp /etc/letsencrypt/live/$domain/cacert.pem $proxy_cert_dir/cacert.pem

chown $user $proxy_cert_dir/*.pem
chmod 700 $proxy_cert_dir/*.pem

mysql --login-path=proxysql_user@localhost --execute="LOAD MYSQL VARIABLES TO RUNTIME" 
mysql --login-path=proxysql_user@localhost --execute="PROXYSQL RELOAD TLS" 

cert_dir=/var/aegir/hostmaster-7.x-3.x/sites/$domain
user=aegir.aegir
cp /etc/letsencrypt/live/$domain/cacert.pem $cert_dir/cacert.pem
rm /etc/letsencrypt/live/$domain/cacert.pem

chown $user $cert_dir/*.pem
chmod 700 $cert_dir/*.pem

service orchestrator restart
