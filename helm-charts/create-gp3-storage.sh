#!/bin/bash

# Create gp3 StorageClass
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  encrypted: "true"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
EOF

# Update PostgreSQL PVC to use gp3
kubectl patch pvc eks-app-postgresql -n eks-app -p '{"spec":{"storageClassName":"gp3"}}' || echo "PVC not found, will be created with new StorageClass"

# Update values.yaml to use gp3
sed -i 's/storageClass: gp2/storageClass: gp3/g' values.yaml

echo "Created gp3 StorageClass and updated PVC configuration"