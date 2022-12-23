# Vault usage

## Login

1. Export env variable `VAULT_ADDR`
```sh
export VAULT_ADDR=https://<Vault hostname>:<port>
```

2. Login
```sh
vault login
```

## KV

1. Enable KV secrets engine
```shell
vault secrets enable -path=secrets kv
```

2. Create a secret
```sh
vault kv put secrets/hello target=world
```

3. Query secret
```sh
vault kv get secrets/hello
```

## Policy

