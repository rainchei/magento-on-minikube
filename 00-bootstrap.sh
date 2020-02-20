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

install_kube() {
  kubectl -n kube-system apply -f ./addons/kube-system/kube/
}

install_istio() {
  kubectl -n istio-system apply -f ./addons/istio-system/istio-crds/
  echo "Waiting for istio-crds to be ready..."
  kubectl -n istio-system wait --for=condition=complete job --all --timeout=60s
  kubectl -n istio-system apply -f ./addons/istio-system/istio/
}

main() {
  cd $(dirname $0)

  echo "== Starting to bootstraping."
  echo ""

  echo "Checking prerequisites."
  prerequisites minikube
  prerequisites kubectl
  prerequisites docker

  echo "Setting env."
  setenv

  echo "Starting minikube."
  # Start minikube.
  minikube start \
    --memory=16384 --cpus=4 \
    --kubernetes-version=${KUBE_VERSION} \
    --extra-config=controller-manager.cluster-signing-cert-file="/var/lib/minikube/certs/ca.crt" \
    --extra-config=controller-manager.cluster-signing-key-file="/var/lib/minikube/certs/ca.key" \
    --vm-driver=virtualbox

  # Check if minikube is up and kubectl is properly configured.
  minikube status
  kubectl cluster-info
  # Re-use the docker daemon on local machine inside minikube.
  eval $(minikube docker-env)
  # Create directories for persistent volumes.
  minikube ssh "sudo mkdir /data/elasticsearch /data/mysql /data/redis /data/magento"
  minikube ssh "sudo chown -R 1000:1000 /data/"

  echo "Creating required namespaces."
  kubectl create --save-config namespace istio-system
  kubectl create --save-config namespace app && \
    kubectl label namespace app istio-injection=enabled
  kubectl create --save-config namespace db

  echo "Installing addons."
  install_kube
  install_istio

  echo ""
  echo "== Done for bootstrapping."
}


main
