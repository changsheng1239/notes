# Kubernetes (k8s) Installation Guide on Debian 10
---
## TLDR; Run this on all nodes (Step 3-5)
```
curl https://koala.sql.com.my/kubernetes/install | bash
```
### Run this on control plane 1
```
cat > /tmp/config.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
networking:
  podSubnet: "172.16.0.0/16"
controlPlaneEndpoint: "10.10.1.201:6443" 
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF
```
```
kubeadm init --config /tmp/config.yaml --upload-certs
```
```
kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
```
Join the rest of the master node and worker using `kubeadm` command provided by the `kubeadm init`

---
## [Bootstrap Using Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)

### [Pre-requisites](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin)
For every nodes:
1. Verify unique MAC address  `ip link`
2. Verify unique product uuid `sudo cat /sys/class/dmi/id/product_uuid`
3. Make sure iptables can see bridged traffic.
```
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system
```
4. Install `kubeadm`, `kubelet` and `kubectl`
```
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2 && \
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update && \
sudo apt-get install -y kubelet kubeadm kubectl && \
sudo apt-mark hold kubelet kubeadm kubectl 
```
5. Install [containerd](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd)
```
apt-get update && apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2 && \
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian/ \
    $(lsb_release -cs) \
    stable" && \
apt-get update && apt-get install -y containerd.io && \
mkdir -p /etc/containerd && \
containerd config default > /etc/containerd/config.toml && \
sed -i -e '/systemd_cgroup/s/false/true/' /etc/containerd/config.toml && \
systemctl restart containerd
```

To use systemd as cgroup driver for `containerd`, edit `/etc/containerd/config.toml`:
```
plugins.cri.systemd_cgroup = true
```


---
### Init cluster
*if using systemd as cgroup driver*
**config.yaml**
```
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
networking:
  podSubnet: "172.16.0.0/16"
controlPlaneEndpoint: "10.10.1.201:6443" 
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
```
1. Run `kubeadm init`
```
kubeadm init --config config.yaml --upload-certs 
```
2. Install `Calico network plugin`
```
kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
```
3. Join the rest of master nodes and worker nodes using commands from step 1. 