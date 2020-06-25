High Availability Kubernetes Cluster
- 
![](http://www.programmersought.com/images/803/e32961285469d826db1df4ce0b034dab.png)
This guide is for setting up k8s cluster with 6 nodes: 

| Nodes      | IP             | role   |
| ---------- | -------------- |:------:|
| fx-debian-0| 192.168.99.103 |master  |
| fx-debian-4| 192.168.99.171 |master  |
| fx-debian-5| 192.168.99.181 |master  |
| fx-debian-1| 192.168.99.172 |worker  |
| fx-debian-2| 192.168.99.175 |worker  |
| fx-debian-3| 192.168.99.174 |worker  |
|Virtual IP|192.168.99.225|

*Adjust value accordingly when followng this guide*  
**Note: The Virtual IP should be in same subnet (or just reacheable?) by other nodes**

# Setting for all nodes
All nodes need:
* [Disable swap](#disable-swap)
* [Container runtime](#install-container-runtime)
* [Unique `MAC` and `uuid`](#check-the-mac-address-and-product_uuid)
* [Install `kubeadm`, `kubelet` and `kubectl`](#install-kubeadm-kubelet-and-kubectl)

## Disable swap:
```
sudo swapoff -a
``` 
Disable swap on future start up:
```
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```
`reboot` and see if the swap is off, it is off if it is not listed in `swapon -s`.  
If it doesn't work, [remove swap partition](https://medium.com/@cloud2help/how-to-create-or-remove-a-swap-memory-in-linux-99b7c09ec7b3) listed in `cat /proc/swaps`.
## Install Container Runtime
### [Containerd](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd)
```
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system
```
```
apt-get update && apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian/ \
    $(lsb_release -cs) \
    stable"
apt-get update && apt-get install -y containerd.io
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
```
### Docker
```
sudo apt-get install \apt-transport-https \ca-certificates \curl \gnupg2 \software-properties-common
```
```
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
```
```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```
Test the installation by running a sample container:
`sudo docker run hello-world`

## Check the `MAC address` and `product_uuid`
Make sure each node have unique `MAC` and `uuid`
> MAC:  `ip link`  
> uuid: `sudo cat /sys/class/dmi/id/product_uuid`

## [Ensure `iptables` tooling does not use the `nftables` backend](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#ensure-iptables-tooling-does-not-use-the-nftables-backend)
```
# ensure legacy binaries are installed
sudo apt-get install -y iptables arptables ebtables

# switch to legacy versions
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo update-alternatives --set arptables /usr/sbin/arptables-legacy
sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy
```

## Install `kubeadm`, `kubelet` and `kubectl`:
```
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

# Control Plane Load Balancer setup
https://blogs.vmware.com/cloudnative/2019/05/22/kube-apiserver-load-balancers-on-premises-kubernetes-clusters/

# Setting for master nodes
## keepalived
```
sudo apt-get install -y keepalived
```
Enable ip forward:
```
cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 1
EOF
```
Verify:
```
sysctl -p
# net.ipv4.ip_forward = 1
```
Configure keepalived:
```
sudo nano /etc/keepalived/keepalived.conf
```
```
! Configuration File for keepalived

global_defs {
   router_id LVS_DEVEL
   notification_email {
     fxshu@sql.com.my
   }
   notification_email_from k8s+LoadBalancer@sql.com.my
   smtp_server smtp.lan.sql.com.my:25
   smtp_connect_timeout 30
}

vrrp_script check_haproxy {
    script "killall -0 haproxy"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 250
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass some-password
    }
    virtual_ipaddress {
        192.168.99.225
    }
    track_script {
        check_haproxy
    }
}
```
Start the service:
```
systemctl enable keepalived.service
systemctl stop keepalived.service 
systemctl restart keepalived.service
systemctl status keepalived.service 
```
Inspect with :
```
ip address show eth0
```
**Each nodes set different priority.**

## haproxy
Enable non-local bind:
```
cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_nonlocal_bind = 1
EOF
```
Install:
```
curl https://haproxy.debian.net/bernat.debian.org.gpg | apt-key add -
echo deb http://haproxy.debian.net buster-backports-2.0 main | tee /etc/apt/sources.list.d/haproxy.list
apt-get update
apt-get install -y haproxy=2.0.\*
```
Configure:
```
nano /etc/haproxy/haproxy.cfg
```
```
global
        log /dev/log    local0
        log /dev/log    local1 notice
        log 127.0.0.1   local2
        chroot  /var/lib/haproxy
        maxconn 4000
        pidfile /var/run/haproxy.pid
        stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats socket /var/lib/haproxy/stats
        stats timeout 30s
        user haproxy
        group haproxy
        daemon

        # Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private

        # See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        option http-server-close
        option forwardfor       except 127.0.0.0/8
        option redispatch
        retries                 3
        timeout http-request    10s
        timeout queue           1m
        timeout connect         10s
        timeout client          1m
        timeout server          1m
        timeout http-keep-alive 10s
        timeout check           10s
        maxconn                 3000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

#---------------------------------------------------------------------
# kubernetes apiserver frontend which proxys to the backends
#---------------------------------------------------------------------
frontend kubernetes-apiserver
        mode            tcp
        bind            *:16443
        option          tcplog
        default_backend kubernetes-apiserver

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend kubernetes-apiserver
        mode    tcp
        balance roundrobin
        server  fx-debian-0 192.168.99.103:6443 check
        server  fx-debian-4 192.168.99.171:6443 check
        server  fx-debian-5 192.168.99.181:6443 check

#---------------------------------------------------------------------
# collection haproxy statistics message
#---------------------------------------------------------------------
listen stats
        bind            *:1080
        stats auth      admin:awesomePassword
        stats refresh   5s
        stats realm     HAProxy\ Statistics
        stats uri       /admin?stats
```
Start the service:
```
systemctl enable haproxy.service 
systemctl stop haproxy.service 
systemctl start haproxy.service 
systemctl status haproxy.service
```
Inspect with:
```
ss -lnt | grep -E "16443|1080"
# LISTEN     0      128          *:1080                     *:*                  
# LISTEN     0      128          *:16443                    *:*
```
## system config
TODO Unknown purpose:
```
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```

Set up `hosts` file:
```
cat >> /etc/hosts << EOF
192.168.99.225 cluster.kube.com

192.168.99.103 fx-debian-0
192.168.99.171 fx-debian-4
192.168.99.181 fx-debian-5
EOF
```

## Initiate cluster with `kubeadm`
Identify which node is using the vrrp address of `keepalived` by checking the ip interface on each address:
```
ip a
```
The following commands will need to be on that node.  
Set up a `kubeadm` config file:
```
cat > kubeadm-config.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: v1.17.0
apiServer:
  certSANs:
    - "cluster.kube.com"
controlPlaneEndpoint: "cluster.kube.com:16443"
networking:
  podSubnet: "172.16.0.0/16"
EOF
```
> podSubnet should be changed if it overlap host network
> if Flannel is to be used, set the podSubnet to 10.244.0.0/16

Initiate kubeadm:
```
kubeadm init --config kubeadm-config.yaml
```
Wait til it is done the follow the instruction to set up the cluster setting:
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Install network plugin 
Calico:
Please refer to [Calico documentation](https://docs.projectcalico.org/v3.10/getting-started/kubernetes/installation/calico) when installing for production. This guide follow guide to install for less than 50 nodes setup.
```
curl https://docs.projectcalico.org/v3.11/manifests/calico.yaml -O
kubectl apply -f calico.yaml
```
Flannel:
```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

## Copy necessary files to other master nodes
### With root ssh access
```
ssh root@fx-debian-4 mkdir -p /etc/kubernetes/pki/etcd
scp /etc/kubernetes/admin.conf root@fx-debian-4:/etc/kubernetes
scp /etc/kubernetes/pki/{ca.*,sa.*,front-proxy-ca.*} root@fx-debian-4:/etc/kubernetes/pki
scp /etc/kubernetes/pki/etcd/ca.* root@fx-debian-4:/etc/kubernetes/pki/etcd
```

### Without root ssh access
The files permission need to be modified so it can be sent via a user without root access (in this case the username is `manager`).
```
### On main master nodes
chown -R manager /etc/kubernetes/

### On target master nodes
scp manager@fx-debian-0:/etc/kubernetes/admin.conf /etc/kubernetes
mkdir /etc/kubernetes/pki
scp manager@fx-debian-0:/etc/kubernetes/pki/{ca.*,sa.*,front-proxy-ca.*} /etc/kubernetes/pki
mkdir /etc/kubernetes/pki/etcd
scp manager@fx-debian-0:/etc/kubernetes/pki/etcd/ca.* /etc/kubernetes/pki/etcd

### On main master nodes, change the permission back
chown -R root /etc/kubernetes/
```

## Join other master nodes
The join command is given when `kubeadm init` is run on the main master. If it was lost, it can be retrieved by the following commands:
```
kubeadm token create --print-join-command
### output: kubeadm join cluster.kube.com:16443 --token [token.name]     --discovery-token-ca-cert-hash [sha256]
```
This `kubeadm join` command can be used to join worker nodes. Master nodes require addition parameter, shown below.  

Retrieve cert-key by running:
```
kubeadm init phase upload-certs --upload-certs
```
  
Combine the output to form a master join command line, e.g.:
```
kubeadm join cluster.kube.com:16443 --token wp1ejl.znur57k26elrcyl6     --discovery-token-ca-cert-hash sha256:b3c20f79a272afd74451f14921ea3ba32e7d8b6f7bdc314889a2749b855a2d31 --control-plane --certificate-key b0e7115f85a9c092b47855f91514cb6972066479ec7fcb61f8929a6ccb542a2d
```

Type the following and watch the pods of the control plane components get started:
```
kubectl get pod -n kube-system -w

watch kubectl get pods --all-namespaces
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl get nodes -o wide
```

> If error `kubectl unable to connect to server: x509: certificate signed by unknown authority` is encountered, try [this solution](https://stackoverflow.com/a/53321499/8245053).

# Joining worker node
Add an entry so the cluster domain can be resolved:
```
cat >> /etc/hosts << EOF
192.168.99.225 cluster.kube.com
EOF
```
If the `kube join` command is lost, it can be retrieved by running this command on master nodes:
```
kubeadm token create --print-join-command
```
Run the `kube join` command, e.g.:
```
kubeadm join cluster.kube.com:16443 --token kobrdb.tzo2memlrdg4vu09     --discovery-token-ca-cert-hash sha256:c9a0325ef0944f95ec9b6779a0983e13326b2c30af8c0c6ef114221f68d87a83 
```
Token might be expired, in which case, create new token on master node with:
```
kubeadm token create
```

If worker node shows error: 
>  [ERROR CRI]: container runtime is not running: output: time="2020-02-26T16:58:49+08:00" level=fatal msg="getting status of runtime failed: rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService"

Try the solution in [this thread](https://github.com/kubernetes/kubernetes/issues/73189#issuecomment-479278959).

# Optional
## Add `kubectl-alias`
Get the script and put it in `$HOME` directory.
```
wget -O ~/.kubectl_aliases https://raw.githubusercontent.com/ahmetb/kubectl-alias/master/.kubectl_aliases
```
Source it.
```
source ~/.kubectl_aliases
```
Make it run on boot.
```
cat >> ~/.bashrc << EOF
[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases
EOF
```
## Install `kubectx`
```
sudo apt install kubectx
```

## Dashboard Setup
Deploy with recommended setup:
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc5/aio/deploy/recommended.yaml
```

### NodePort
Edit service setting:
```
kubectl -n kubernetes-dashboard edit service kubernetes-dashboard
```
Change from `type: ClusterIP` to `type: NodePort`.
> Space after colon is important!

> Optionally, the set a node port number so it won't be randomize. It is done by changing the line `nodePort: xxxx` to `nodePort: 31443`.

Then the dashboard can be accessed by visiting the URL `https://<any-node-IP>:<NodePort-number>`

The `NodePort` number can be checked by running the following command:
```
kubectl get svc kubernetes-dashboard -n kubernetes-dashboard -o go-template='{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}'
```
Refer to the [docs](https://github.com/kubernetes/dashboard/tree/master/docs) and add new arguments to customize.
### Login 
A service account token is needed to login.  
```
kubectl create serviceaccount dashboarduser -n default

kubectl create clusterrolebinding dashboarduser-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboarduser

kubectl get secret $(kubectl get serviceaccount dashboarduser -n default -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" -n default | base64 --decode
```

## Metric
1.  Make sure you have git installed:
```
apt-get install -y git
```
2.  Clone the official kubernetes metrics server git and change directory into it.
```
git clone https://github.com/kubernetes-sigs/metrics-server
cd metrics-server
```
3.  If the kubernetes is not TLS secured (like the setup above), the deployment need have some extra arguments added. Edit the deployment file `deploy/kubernetes/metrics-server-deployment.yaml`. Add `--kubelet-insecure-tls` and `--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname` in the `args` segment.
```
        args:
          - --cert-dir=/tmp
          - --secure-port=4443
          - --kubelet-insecure-tls
          - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
```
4.  Deploy it
```
kubectl apply -f deploy/kubernetes/
```
If it is deployed successfully then the following commands will work correctly:
```
kubectl top nodes
ubectl top pods
```
# Reference
*   https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/#before-you-begin
*   http://www.programmersought.com/article/5222255935/
### dashboard setup
*   http://www.joseluisgomez.com/containers/kubernetes-dashboard/
*   https://github.com/kubernetes/dashboard/tree/master/docs
### Metric
*   https://github.com/kubernetes-sigs/metrics-server