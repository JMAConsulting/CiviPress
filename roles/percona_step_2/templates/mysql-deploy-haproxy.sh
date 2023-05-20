#!/bin/sh
domain={{hostvars[inventory_hostname]['preseed_hostname']}}.{{hostvars[inventory_hostname]['preseed_domain']}}
cert_dir=/var/lib/mysql
user=mysql.mysql
cp /etc/letsencrypt/live/$domain/privkey.pem $cert_dir/privkey.pem

openssl x509 -in /etc/letsencrypt/live/$domain/fullchain.pem > $cert_dir/fullchain.pem

wget https://curl.se/ca/cacert.pem -P /etc/letsencrypt/live/$domain/
cat /etc/letsencrypt/live/$domain/fullchain.pem >> /etc/letsencrypt/live/$domain/cacert.pem
cp /etc/letsencrypt/live/$domain/cacert.pem $cert_dir/cacert.pem
rm /etc/letsencrypt/live/$domain/cacert.pem

chown $user $cert_dir/*.pem
chmod 700 $cert_dir/*.pem

mysql --login-path=renew_tls_user@localhost --execute="ALTER INSTANCE RELOAD TLS" 

hp_cert_dir=/var/lib/haproxy
user=haproxy.haproxy
cat $cert_dir/fullchain.pem $cert_dir/privkey.pem > $hp_cert_dir/certkey.pem
chown $user $hp_cert_dir/*.pem
chmod 700 $hp_cert_dir/*.pem

hp_loaded_cert_dir=/etc/haproxy/certs
user=haproxy.haproxy
cp $hp_cert_dir/certkey.pem $hp_loaded_cert_dir/certkey.pem
echo -e "set ssl cert /etc/haproxy/certs/certkey.pem <<\n$(cat /var/lib/haproxy/certkey.pem)\n" | socat tcp-connect:127.0.0.1:9999 -
echo commit ssl cert /etc/haproxy/certs/certkey.pem | socat tcp-connect:127.0.0.1:9999 -
chown $user $hp_loaded_cert_dir/*.pem
chmod 700 $hp_loaded_cert_dir/*.pem