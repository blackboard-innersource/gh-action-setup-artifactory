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

require_env "ARTIFACTORY_YARN_ID_TOKEN" "$ARTIFACTORY_YARN_ID_TOKEN" || return 1

if [ "$ARTIFACTORY_YARN_ID_TOKEN" == "false" ]; then
    echo "Skipping yarn setup because ARTIFACTORY_YARN_ID_TOKEN=$ARTIFACTORY_YARN_ID_TOKEN"
    return 0
  fi

setup_yarn() {
  local lines=()
  local yarnrc

  lines+=("npmAlwaysAuth: true")
  lines+=("npmAuthToken: ${ARTIFACTORY_YARN_ID_TOKEN}")
  yarnrc="$HOME/.yarnrc.yml"
  echo "$lines" > "$yarnrc"

  echo "Wrote to $yarnrc"
  return 0
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  if setup_yarn "$@"; then
    exit 0
  fi
  exit 1
fi
