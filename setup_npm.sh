#!/usr/bin/env bash

require_var() {
  if [ -z "$1" ]; then
    >&2 echo "$2"
    return 1
  fi
  return 0
}

require_env() {
  require_var "$2" "Missing env var '$1'"
}

encode() {
  local os
  os=$(uname | tr '[:upper:]' '[:lower:]')
  if [ "$os" == "linux" ]; then
    echo "$1" | base64 --wrap=0
  else
    echo "$1" | base64
  fi
}

setup_npm() {
  if [ "$ARTIFACTORY_SETUP_NPM" == "false" ]; then
    echo "Skipping pip setup because ARTIFACTORY_SETUP_NPM=$ARTIFACTORY_SETUP_NPM"
    return 0
  fi

  require_env "ARTIFACTORY_USERNAME" "$ARTIFACTORY_USERNAME" || return 1
  require_env "ARTIFACTORY_TOKEN" "$ARTIFACTORY_TOKEN" || return 1
  require_env "ARTIFACTORY_NPM_REGISTRY" "$ARTIFACTORY_NPM_REGISTRY" || return 1

  local key
  key=${ARTIFACTORY_NPM_REGISTRY#"https://"}

  cat > "$HOME/.npmrc" << EOF
registry=$ARTIFACTORY_NPM_REGISTRY
//$key:_password=$(encode "$ARTIFACTORY_TOKEN")
//$key:username=$ARTIFACTORY_USERNAME
//$key:always-auth=true

EOF

  return 0
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  if setup_npm "$@"; then
    exit 0
  fi
  exit 1
fi