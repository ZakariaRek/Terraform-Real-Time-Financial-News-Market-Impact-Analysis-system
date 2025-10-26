#!/bin/bash
# modules/eks/user_data.sh
# User data script for EKS worker nodes
 set -o xtrace

 # Bootstrap the node
 /etc/eks/bootstrap.sh '${cluster_name}' \
   --b64-cluster-ca '${cluster_ca}' \
   --apiserver-endpoint '${cluster_endpoint}' \
   --kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=normal'

 echo "Node bootstrap completed successfully"
