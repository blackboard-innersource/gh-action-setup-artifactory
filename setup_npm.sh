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

# Linux base64 wraps while macOS does not
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

  local scope
  scope=""
  if [ -n "$ARTIFACTORY_NPM_SCOPE" ]; then
    scope="${ARTIFACTORY_NPM_SCOPE}:"
  fi

  local key
  key=${ARTIFACTORY_NPM_REGISTRY#"https://"}

  local npmrc
  npmrc="$HOME/.npmrc"

  cat > "$npmrc" << EOF
${scope}registry=$ARTIFACTORY_NPM_REGISTRY
//$key:_password=$(encode "$ARTIFACTORY_TOKEN")
//$key:username=$ARTIFACTORY_USERNAME
//$key:always-auth=true

EOF

  echo "Wrote to $npmrc"

  return 0
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  if setup_npm "$@"; then
    exit 0
  fi
  exit 1
fi