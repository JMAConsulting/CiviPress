#!/bin/sh
pkill -9 vault
vault agent -config=vault-agent-config.hcl &
# sleep 60
sleep 5
new_token="$( cat /var/lib/vault/vault_agent/vault_token )"
sed -i "s/token=.*/token=${new_token}/" /var/lib/mysql-keyring/keyring_vault.conf
mysql --login-path=renew_token_user@localhost --execute="UNINSTALL PLUGIN keyring_vault";
mysql --login-path=renew_token_user@localhost --execute="INSTALL PLUGIN keyring_vault SONAME 'keyring_vault.so';"