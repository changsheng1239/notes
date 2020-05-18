# Talos Installation Guide on Baremetal (IPXE chain matchbox)

## Setup [Matchbox](https://matchbox.psdn.io/deployment/)

**docker run command**

```bash
mkdir -p /var/lib/matchbox/assets
sudo docker run --net=host --rm -v /var/lib/matchbox:/var/lib/matchbox:Z -v /etc/matchbox:/etc/matchbox:Z,ro quay.io/poseidon/matchbox:latest -address=0.0.0.0:8080 -log-level=debug
```

**docker compose**

```docker
version: '3.3'
services:
    matchbox:
        image: 'quay.io/poseidon/matchbox:latest'
        network_mode: host
        volumes:
            - '/var/lib/matchbox:/var/lib/matchbox:Z'
            - '/etc/matchbox:/etc/matchbox:Z,ro'
        restart: always
        command: "-address=0.0.0.0:8080 -log-level=debug"
```

**Test Matchbox Installation**

Running this command `curl http://host:8080` should return:

    matchbox

Add a new entry to boot.ipxe

    chain http://host:8080/boot.ipxe

---

## Setup Talos in matchbox

1. Download `talosctl`, `vmlinuz`, and `initramfs.xz` from [talos/releases](https://github.com/talos-systems/talos/releases)
2. `chmod +x talosctl && mv talosctl /usr/bin`
3. `mv vmlinuz initramfs.xz /var/lib/matchbox/assets`
4. `talosctl gen config talos-k8s-metal-tutorial https://<load balancer IP or DNS>:<port>`
5. `mv *.yaml /var/lib/matchbox/assets && cat talosconfig > ~/.talos/config`
6. `mkdir /var/lib/matchbox/profiles /var/lib/matchbox/groups`
7. Create multiple files under profiles and groups

### Profiles

**/var/lib/matchbox/profiles/init.json**

```json
{
  "id": "init",
  "name": "init",
  "boot": {
    "kernel": "/assets/vmlinuz",
    "initrd": ["/assets/initramfs.xz"],
    "args": [
      "initrd=initramfs.xz",
      "page_poison=1",
      "slab_nomerge",
      "slub_debug=P",
      "pti=on",
      "console=tty0",
      "console=ttyS0",
      "printk.devkmsg=on",
      "talos.platform=metal",
      "talos.config=http://matchbox.talos.dev/assets/init.yaml"
    ]
```

**/var/lib/matchbox/profiles/controlplane.json**

```json
{
  "id": "control-plane",
  "name": "control-plane",
  "boot": {
    "kernel": "/assets/vmlinuz",
    "initrd": ["/assets/initramfs.xz"],
    "args": [
      "initrd=initramfs.xz",
      "page_poison=1",
      "slab_nomerge",
      "slub_debug=P",
      "pti=on",
      "console=tty0",
      "console=ttyS0",
      "printk.devkmsg=on",
      "talos.platform=metal",
      "talos.config=http://matchbox.talos.dev/assets/controlplane.yaml"
    ]
  }
}
```

**/var/lib/matchbox/profiles/worker.json**

```json
{
  "id": "default",
  "name": "default",
  "boot": {
    "kernel": "/assets/vmlinuz",
    "initrd": ["/assets/initramfs.xz"],
    "args": [
      "initrd=initramfs.xz",
      "page_poison=1",
      "slab_nomerge",
      "slub_debug=P",
      "pti=on",
      "console=tty0",
      "console=ttyS0",
      "printk.devkmsg=on",
      "talos.platform=metal",
      "talos.config=http://matchbox.talos.dev/assets/join.yaml"
    ]
  }
}
```

### Groups

> profile must match the .json filename under /var/lib/matchbox/profiles

**/var/lib/matchbox/groups/init.json**

```json
{
  "id": "control-plane-1",
  "name": "control-plane-1",
  "profile": "init",
  "selector": {
    "mac": "00:1d:ab:sc:cd" master-1 node mac address
  }
}
```

**/var/lib/matchbox/groups/controlplane2.json**

```json
{
  "id": "control-plane-2",
  "name": "control-plane-2",
  "profile": "controlplane",
  "selector": {
    "mac": "00:1d:ab:sc:cd" master-2 node mac address
  }
}
```

**/var/lib/matchbox/groups/controlplane3.json**

```json
{
  "id": "control-plane-3",
  "name": "control-plane-3",
  "profile": "control-plane",
  "selector": {
    "mac": "00:1d:ab:sc:cd" master-3 node mac address
  }
}
```

**/var/lib/matchbox/groups/worker.json**

> mac address selector is ignored so worker profile will be the default

```json
{
  "id": "default",
  "name": "default",
  "profile": "worker"
}
```

### Talosctl usage

Check the status of talos node

    talosctl -e master-node-ip services

Download kubeconfig to current directory

    talosctl -e master-node-ip kubeconfig .
