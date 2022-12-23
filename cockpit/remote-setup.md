# Remote Cockpit on WSL

> Only works in WSL 2 due to podman limitation

1. Start wsl
2. Install podman 
```sh
sudo apt -y install podman
```
1. Copy your desired ssh key to `~/.ssh`
2. Run `cockpit/ws` using command below
```
podman run --rm \  -e COCKPIT_SSH_KEY_PATH=/root/.ssh/id_ed25519 -v ~/.ssh:/root/.ssh -p 9090:9090 quay.io/cockpit/ws
```
1. Visit `localhost:9090` and you shall see cockpit login screen. 
> If your key is encrypted by password, enter it into the password field