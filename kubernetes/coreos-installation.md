# Kubernetes Installation on CoreOS/FlatCar

## Prerequisite
Change hostname for each node
```bash
hostnamectl set-hostname <hostname>
```
Edit **/etc/hosts** and replace *localhost* as *hostname*

## Install CNI plugins (required for most pod network):
```bash  
CNI_VERSION="v0.8.2"
mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz
```

## Install crictl (required for kubeadm / Kubelet Container Runtime Interface (CRI))
```bash
CRICTL_VERSION="v1.16.0"
mkdir -p /opt/bin
curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C /opt/bin -xz
```

## Install kubeadm, kubelet, kubectl and add a kubelet systemd service:
```bash
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

mkdir -p /opt/bin
cd /opt/bin
curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
chmod +x {kubeadm,kubelet,kubectl}

curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```

## Initialize cluster using kubeadm (master node)
```bash
sudo kubeadm init --config kubeadm-custom.yaml
``` 
**kubeadm-custom.yaml**
```
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.17.0
controllerManager:
  extraArgs:
    flex-volume-plugin-dir: "/var/lib/kubelet/volumeplugins"
networking:
  podSubnet: 192.168.0.0/16
```

After kubeadm init, run this as regular user (`core`)
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Install CNI (master node)
### **Calico**
    curl https://docs.projectcalico.org/v3.8/manifests/calico.yaml -O
Edit `calico.yaml`, changed the path (default path is ro), need to match the path in `kube-contoller-manager`
```
# Used to install Flex Volume Driver
    - name: flexvol-driver-host
        hostPath:
        type: DirectoryOrCreate
        path: /var/lib/kubelet/volumeplugins/nodeagent~uds
```
    kubectl apply -f calico.yaml

## Join the cluster (worker node)
Run `kubeadm join` generated from previous `kubeadm init` 

Example:
```bash
sudo kubeadm join 192.168.9.67:6443 --token cd583y.rsra33fa1hvvs4js     --discovery-token-ca-cert-hash sha256:eb2e002c57fb99e5f58af9a157df33a7128424a5e5626f2f1c14c35189716627
```

## Join the cluster (master node) 
Run `kubeadm join --control-plane` generated from previous `kubeadm init` 

Example:
```bash
sudo kubeadm join 192.168.9.67:6443 --token cd583y.rsra33fa1hvvs4js     --discovery-token-ca-cert-hash sha256:eb2e002c57fb99e5f58af9a157df33a7128424a5e5626f2f1c14c35189716627 --control-plane
```

## Reference
1. [Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl)
2. [Creating a single control-plane cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
3. [Kubernetes on DigitalOcean with CoreOS](https://gist.github.com/kevashcraft/5aa85f44634c37a9ee05dde7e83ac7e2)
4. [Are the Calico manifests compatible with CoreOS?](https://docs.projectcalico.org/v3.10/reference/faq#are-the-calico-manifests-compatible-with-coreos)
