#!/bin/bash
set -eo pipefail

prerequisites() {
  if ! ${1} &> /dev/null; then
    echo "ERROR: failed to find \"${1}\"." >&2  # Send message to stderr.
    exit 101
  else
    echo "${1} ok."
  fi
}

setenv() {
  export KUBE_VERSION="v1.17.0"
  export KUBECONFIG="${HOME}/.kube/config"
}

main() {
  cd $(dirname $0)

  echo "== Starting to bootstrap."

  echo "Checking prerequisites."
  prerequisites minikube
  prerequisites kubectl
  prerequisites docker
  echo ""

  echo "Starting minikube."
  # Start minikube.
  setenv
  minikube start \
    --memory='8000mb' --cpus=2 --disk-size='20000mb' \
    --kubernetes-version=${KUBE_VERSION} \
    --extra-config=controller-manager.cluster-signing-cert-file="/var/lib/minikube/certs/ca.crt" \
    --extra-config=controller-manager.cluster-signing-key-file="/var/lib/minikube/certs/ca.key" \
    --extra-config=apiserver.service-node-port-range=80-30000 \
    --vm-driver=virtualbox
  echo ""

  # Check if minikube is up and kubectl is properly configured.
  minikube status
  kubectl cluster-info
  # Create directories for persistent volumes.
  minikube ssh "sudo mkdir -p /data/magento && sudo chown 33:33 /data/magento"
  minikube ssh "sudo mkdir -p /data/mysql && sudo chown 1000:1000 /data/mysql"
  # Elasticsearch requires vm.max_map_count to be at least 262144.
  # If your OS already sets up this number to a higher value, feel free
  # to remove this line.
  minikube ssh "sudo /sbin/sysctl -w vm.max_map_count=262144"

  echo "Enabling minikube addons."
  minikube addons enable metrics-server
}

## ============================
main

