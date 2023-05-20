#!/bin/sh
echo "export VAULT_ADDR='https://{{hostvars[inventory_hostname]['preseed_hostname']}}.{{hostvars[inventory_hostname]['preseed_domain']}}:8200'"
echo "export VAULT_CACERT='/etc/letsencrypt/live/{{hostvars[inventory_hostname]['preseed_hostname']}}.{{hostvars[inventory_hostname]['preseed_domain']}}/fullchain.pem'"