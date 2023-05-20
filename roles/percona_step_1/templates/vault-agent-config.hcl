pid_file = "./pidfile"

vault {
  address = "https://{{active_vault_address}}:8200"
}

auto_auth {
  method {
    type      = "approle"

    config = {
      role_id_file_path = "./vault_role_id"
      secret_id_file_path = "./vault_wrapped_secret_id"
      remove_secret_id_file_after_reading = false
    }
  }

  sink {
    type = "file"
    config = {
      path = "sink_file_wrapped_1.txt"
    }
  }

  sink {
    type = "file"
    config = {
      path = "./vault_token"
    }
  }
}

cache {
  use_auto_auth_token = true
}

listener "tcp" {
  address = "{{hostvars[inventory_hostname]['preseed_ipv4_address']}}:8100"
  tls_disable = false
  tls_cert_file="/etc/letsencrypt/live/{{hostvars[inventory_hostname]['preseed_hostname']}}.{{hostvars[inventory_hostname]['preseed_domain']}}/fullchain.pem"
  tls_key_file="/etc/letsencrypt/live/{{hostvars[inventory_hostname]['preseed_hostname']}}.{{hostvars[inventory_hostname]['preseed_domain']}}/privkey.pem"
}
