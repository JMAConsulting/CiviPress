path "kv/*" {
    capabilities = ["read", "list"]
}

path "kv/data/dc1/*" {
    capabilities = ["create", "read", "delete", "update", "list"]
}