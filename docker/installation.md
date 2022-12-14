## Docker installation

### Docker For Linux Installation (Debian amd64)

1. Install using convenience script.
```shell
curl -fsSL https://get.docker.com | sudo sh
```

[Snippet](https://git.dev.sql.com.my/snippets/26)
```bash=
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
```bash
curl -s https://git.dev.sql.com.my/snippets/26/raw | bash 
```

[Full Guide](https://docs.docker.com/install/linux/docker-ce/debian/)