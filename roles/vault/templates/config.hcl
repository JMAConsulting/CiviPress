listener "tcp" {
   address = "{{hostvars[inventory_hostname]['preseed_ipv4_address']}}:8200"
   tls_disable = "false"
   tls_cert_file="/etc/letsencrypt/live/{{hostvars[inventory_hostname]['preseed_hostname']}}.{{hostvars[inventory_hostname]['preseed_domain']}}/fullchain.pem"
   tls_key_file="/etc/letsencrypt/live/{{hostvars[inventory_hostname]['preseed_hostname']}}.{{hostvars[inventory_hostname]['preseed_domain']}}/privkey.pem"
}

storage "raft" {
  path    = "/var/lib/vault/data"
  node_id = "{{hostvars[inventory_hostname]['preseed_hostname']}}"
}

api_addr = "https://{{hostvars[inventory_hostname]['preseed_ipv4_address']}}:8200"
cluster_addr = "https://{{hostvars[inventory_hostname]['preseed_ipv4_address']}}:8201"
ui = true