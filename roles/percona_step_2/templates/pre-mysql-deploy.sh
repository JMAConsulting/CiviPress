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
