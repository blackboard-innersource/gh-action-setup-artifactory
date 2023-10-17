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

setup_go() {
  if [ "$ARTIFACTORY_SETUP_GO" == "false" ]; then
    echo "Skipping go setup because ARTIFACTORY_SETUP_GO=$ARTIFACTORY_SETUP_GO"
    return 0
  fi

  require_env "ARTIFACTORY_USERNAME" "$ARTIFACTORY_USERNAME" || return 1
  require_env "ARTIFACTORY_TOKEN" "$ARTIFACTORY_TOKEN" || return 1

  if [ -z "$ARTIFACTORY_GOPROXY" ]; then
    ARTIFACTORY_GOPROXY="blackboard.jfrog.io/artifactory/api/go/fnds-go"
  fi

  local go_proxy
  go_proxy="https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_TOKEN}@${ARTIFACTORY_GOPROXY}"

  if [ -n "$GITHUB_ACTIONS" ]; then
    echo "GOPROXY=$go_proxy" >> "$GITHUB_ENV"
  else
    export GOPROXY="$go_proxy"
  fi

  echo "Set GOPROXY env"

  return 0
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  if setup_go "$@"; then
    exit 0
  fi
  exit 1
fi