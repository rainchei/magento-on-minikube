#!/bin/bash
set -eo pipefail

setenv() {
  export KUBECONFIG="${HOME}/.kube/config"
}

main() {
  cd $(dirname $0)
  setenv

  local ns="$1"
  local app="$2"
  local app_path="$(pwd)/deployments/${ns}/${app}/"

  if [[ -z "${ns}" ]] || [[ -z "${app}" ]]; then
    usage
  fi

  # must have at least one yaml to proceed
  ls ${app_path} | egrep "[a-z|0-9]+.ya?ml" &> /dev/null \
    || fail "ERROR: must have at least one yaml under ${app_path}" 2

  echo "== Starting to deploy ${ns}/${app}."

  ns_to_apply "${ns}"

  for yml in $(ls ${app_path}); do
    deploy_to_apply "${ns}" "${app}" "${yml}"
  done

  echo "== Done for ${ns}/${app}."
}

usage() {
  echo "Usage: $0 <namespace> <app-name>"
  echo ""
  echo "For example:"
  echo "$0 app magento"
  exit 2
}

ns_to_apply() {
  local ns="$1"

  cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
EOF
}

fail() {
  echo "$1"
  exit "${2-1}"  # Return a code specified by $2 or 1 by default.
}

deploy_to_apply() {
  local ns="$1"
  local app="$2"
  local yml="$3"
  local yml_path="$(pwd)/deployments/${ns}/${app}/${yml}"
  local kubeval="docker run -i --rm --name kubeval -v ${yml_path}:/${ns}/${app}/${yml} garethr/kubeval /${ns}/${app}/${yml}"

  echo "Validating k8s yaml policy."
  cat "${yml_path}" \
    | ${kubeval} \
    || fail "NO PASS." 101 \
  echo "PASS."
  echo ""

  echo "Applying ${yml} for ${ns}/${app}."
  cat "${yml_path}" \
    | kubectl apply -n "${ns}" -f -
  echo ""
}

## ================================================

main "$1" "$2"
