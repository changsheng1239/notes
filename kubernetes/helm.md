# Overview
## Helm Installation
### Binary Releases
1. Download binary from [Github/releases](https://github.com/helm/helm/releases)
2. Unpack it `tar -zxvf helm-v3.0.0-linux-amd64.tar.gz`
3. Move to desired dest `mv linux-amd64/helm /usr/local/bin/helm`

### Installation script
```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

### Usage
#### Add repository
```bash
helm repo add <repo-name> <repo-link>
    
# example to add stable repo
helm repo add stable https://kubernetes-charts.storage.googleapis.com
```

#### Search for a chart
