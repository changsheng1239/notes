
# Vault Installation

## Ubuntu/Debian

1.  Add PGP for the package signing key.
	```shell
	sudo apt update && sudo apt install gpg
	```

2. Add the HashiCorp [GPG key](https://apt.releases.hashicorp.com/gpg "HashiCorp GPG key").

	```shell
	wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
	```

3. Verify the key's fingerprint.

	```shell
	gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
	```

	> The fingerprint must match E8A0 32E0 94D8 EB4E A189 D270 DA41 8C88 A321 9F7B, which can also be verified at [https://www.hashicorp.com/security](https://www.hashicorp.com/security) under "Linux Package Checksum Verification".

4.  Add the official HashiCorp Linux repository.

	```shell
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	```

5. Update and install.

	```shell
	 sudo apt update && sudo apt install vault
	```

---

## Verifying the Installation

After installing Vault, verify the installation worked by opening a new terminal session and checking that the `vault` binary is available. By executing `vault`, you should see help output similar to the following:

```shell-session
vault

Usage: vault <command> [args]

Common commands:
	read Read data and retrieves secrets
	...
Other commands:
	audit Interact with audit devices
	...
```