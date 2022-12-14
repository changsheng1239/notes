# Rancher Longhorn 

## Installation 
### Prerequisite
1. Docker v1.13+
2. Kubernetes v1.14+.
3. open-iscsi has been installed on all the nodes of the Kubernetes cluster, and iscsid daemon is running on all the nodes.
    ```
    apt-get install open-iscsi
    ```
4. A host filesystem supports file extents feature on the nodes to store the data. Currently we support:
    - ext4
    - XFS

### Using Helm
Add Helm repo
```
helm repo add longhorn https://charts.longhorn.io
helm repo update
```
Default  values.yaml
```yaml
# Default values for longhorn.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
image:
  longhorn:
    engine: longhornio/longhorn-engine
    engineTag: v1.0.1
    manager: longhornio/longhorn-manager
    managerTag: v1.0.1
    ui: longhornio/longhorn-ui
    uiTag: v1.0.1
    instanceManager: longhornio/longhorn-instance-manager
    instanceManagerTag: v1_20200514
  pullPolicy: IfNotPresent

service:
  ui:
    type: ClusterIP
    nodePort: null
  manager:
    type: ClusterIP
    nodePort: ""

persistence:
  defaultClass: true
  defaultClassReplicaCount: 3

csi:
  attacherImage: ~
  provisionerImage: ~
  nodeDriverRegistrarImage: ~
  resizerImage: ~
  kubeletRootDir: ~
  attacherReplicaCount: ~
  provisionerReplicaCount: ~
  resizerReplicaCount: ~

defaultSettings:
  backupTarget: ~
  backupTargetCredentialSecret: ~
  createDefaultDiskLabeledNodes: ~
  defaultDataPath: ~
  replicaSoftAntiAffinity: ~
  storageOverProvisioningPercentage: ~
  storageMinimalAvailablePercentage: ~
  upgradeChecker: ~
  defaultReplicaCount: ~
  guaranteedEngineCPU: ~
  defaultLonghornStaticStorageClass: ~
  backupstorePollInterval: ~
  taintToleration: ~
  priorityClass: ~
  registrySecret: ~
  autoSalvage: ~
  disableSchedulingOnCordonedNode: ~
  replicaZoneSoftAntiAffinity: ~
  volumeAttachmentRecoveryPolicy: ~
  mkfsExt4Parameters: ~

privateRegistry:
  registryUrl: ~
  registryUser: ~
  registryPasswd: ~

resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #  cpu: 100m
  #  memory: 128Mi
  # requests:
  #  cpu: 100m
  #  memory: 128Mi
  #

ingress:
  ## Set to true to enable ingress record generation
  enabled: false


  host: xip.io

  ## Set this to true in order to enable TLS on the ingress record
  ## A side effect of this will be that the backend service will be connected at port 443
  tls: false

  ## If TLS is set to true, you must declare what secret will store the key/certificate for TLS
  tlsSecret: longhorn.local-tls

  ## Ingress annotations done as key:value pairs
  ## If you're using kube-lego, you will want to add:
  ## kubernetes.io/tls-acme: true
  ##
  ## For a full list of possible ingress annotations, please see
  ## ref: https://github.com/kubernetes/ingress-nginx/blob/master/docs/annotations.md
  ##
  ## If tls is set to true, annotation ingress.kubernetes.io/secure-backends: "true" will automatically be set
  annotations:
  #  kubernetes.io/ingress.class: nginx
  #  kubernetes.io/tls-acme: true

  secrets:
  ## If you're providing your own certificates, please use this to add the certificates as secrets
  ## key and certificate should start with -----BEGIN CERTIFICATE----- or
  ## -----BEGIN RSA PRIVATE KEY-----
  ##
  ## name should line up with a tlsSecret set further up
  ## If you're using kube-lego, this is unneeded, as it will create the secret for you if it is not set
  ##
  ## It is also possible to create and manage the certificates outside of this helm chart
  ## Please see README.md for more information
  # - name: longhorn.local-tls
  #   key:
  #   certificate:
```
Install
```
kubectl create namespace longhorn-system
helm install longhorn -f values.yaml longhorn/longhorn --namespace longhorn-system
```
