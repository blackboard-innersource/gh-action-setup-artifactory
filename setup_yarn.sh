#!/usr/bin/env bash

set -e

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
    echo -n "$1" | base64 --wrap=0
  else
    echo -n "$1" | base64
  fi
}

setup_yarn() {
  if [ "$ARTIFACTORY_SETUP_NPM" == "false" ]; then
    echo "Skipping npm setup because ARTIFACTORY_SETUP_NPM=$ARTIFACTORY_SETUP_NPM"
    return 0
  fi

  require_env "ARTIFACTORY_USERNAME" "$ARTIFACTORY_USERNAME" || return 1
  require_env "ARTIFACTORY_TOKEN" "$ARTIFACTORY_TOKEN" || return 1
  require_env "ARTIFACTORY_NPM_REGISTRY" "$ARTIFACTORY_NPM_REGISTRY" || return 1

  local configKey
  local npmrc
  local scope
  local scopes
  local parts
  local registry
  local lines=()
  local ident
  local config

  configKey=${ARTIFACTORY_NPM_REGISTRY#"https://"}
  ident=$(encode "$ARTIFACTORY_USERNAME:$ARTIFACTORY_TOKEN")

  lines+=("npmRegistries:")
  lines+=("  //${configKey}:")
  lines+=("    npmAlwaysAuth: true")
  lines+=("    npmAuthIdent: ${ident}")
  
  if [ -n "$ARTIFACTORY_NPM_SCOPES" ]; then
    # Split ARTIFACTORY_NPM_SCOPES by comma
    IFS="," read -r -a scopes <<< "$ARTIFACTORY_NPM_SCOPES"

    lines+=("npmScopes:")
    for scope in "${scopes[@]}"; do
      lines+=("  $scope:")
      lines+=("    npmRegistryServer: $ARTIFACTORY_NPM_REGISTRY")
    done
  fi

  yarnrc="$HOME/.yarnrc.yml"

  # Join the parts array with newline
  config=$( IFS=$'\n'; echo "${parts[*]}" )

  echo "$config" > "$yarnrc"

  echo "Wrote to $yarnrc"

  return 0
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  if setup_yarn "$@"; then
    exit 0
  fi
  exit 1
fi
