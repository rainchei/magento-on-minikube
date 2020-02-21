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
    --memory=16384 --cpus=4 \
    --kubernetes-version=${KUBE_VERSION} \
    --extra-config=controller-manager.cluster-signing-cert-file="/var/lib/minikube/certs/ca.crt" \
    --extra-config=controller-manager.cluster-signing-key-file="/var/lib/minikube/certs/ca.key" \
    --extra-config=apiserver.service-node-port-range=80-30000 \
    --vm-driver=virtualbox
  echo ""

  # Check if minikube is up and kubectl is properly configured.
  minikube status
  kubectl cluster-info
  # Re-use the docker daemon on local machine inside minikube.
  eval $(minikube docker-env)
  # Create directories for persistent volumes.
  minikube ssh "sudo mkdir -p /data/elasticsearch /data/mariadb /data/magento"
  minikube ssh "sudo chown -R 1000:1000 /data/"
  # Elasticsearch requires vm.max_map_count to be at least 262144.
  # If your OS already sets up this number to a higher value, feel free
  # to remove this line.
  minikube ssh "sudo /sbin/sysctl -w vm.max_map_count=262144"

  echo "Enabling minikube addons."
  minikube addons enable metrics-server

  echo "== Done for bootstrap."
}


main


## ====== Documentary-Commands ======

## Istio Bootstraps
#export ISTIO_VERSION='1.4.2'
#helm template $HOME/istio-$ISTIO_VERSION/install/kubernetes/helm/istio-init --name-template istio-init --namespace istio-system \
#  > addons/istio-system/istio-crds/istio-crds.yml
#helm template $HOME/istio-$ISTIO_VERSION/install/kubernetes/helm/istio --name-template istio --namespace istio-system \
#  --set prometheus.enabled=false \
#  --set tracing.enabled=false \
#  \
#  --set pilot.env.PILOT_ENABLE_FALLTHROUGH_ROUTE=1 \
#  --set gateways.istio-ingressgateway.type=NodePort \
#  \
#  > addons/istio-system/istio/istio-install.yml
