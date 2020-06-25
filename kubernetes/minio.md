# Deploy minio using Operator
## Sample PV
edit `capacity`, `path`, `nodeAffinity` accordingly
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: minio-pv
spec:
  capacity:
    storage: 1Ti
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""
  local:
    path: /mnt/disks/ssd1
  nodeAffinity:
    required:
        nodeSelectorTerms:
        - matchExpressions:
        - key: kubernetes.io/hostname
            operator: In
            values:
            - example-node
```

## Create Minio Operator
```bash
kubectl apply -f https://raw.githubusercontent.com/minio/minio-operator/master/minio-operator.yaml
```

## Create Minio Instance
```bash
curl -O https://raw.githubusercontent.com/minio/minio-operator/master/examples/minioinstance.yaml
``` 
1. `service` default to `ClusterIP`
2. `volumeClaimTemplate` according to `pv`

```bash
kubectl apply -f minioinstance.yaml
```

