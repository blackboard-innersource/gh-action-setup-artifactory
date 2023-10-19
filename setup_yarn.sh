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

setup_yarn() {
  # Legacy variable, was named differently from all our other ones
  if [ "$ARTIFACTORY_YARN_SETUP" == "false" ]; then
    echo "Skipping yarn setup because ARTIFACTORY_YARN_SETUP=$ARTIFACTORY_YARN_SETUP"
    return 0
  fi
  if [ "$ARTIFACTORY_SETUP_YARN" == "false" ]; then
    echo "Skipping yarn setup because ARTIFACTORY_SETUP_YARN=$ARTIFACTORY_SETUP_YARN"
    return 0
  fi

  require_env "ARTIFACTORY_USERNAME" "$ARTIFACTORY_USERNAME" || return 1
  require_env "ARTIFACTORY_TOKEN" "$ARTIFACTORY_TOKEN" || return 1

  local yarnrc
  yarnrc="$HOME/.yarnrc.yml"
  cat > "$yarnrc" << EOF
npmAlwaysAuth: true
npmAuthToken: ${ARTIFACTORY_USERNAME}:${ARTIFACTORY_TOKEN}

EOF
  echo "Wrote to $yarnrc"
  return 0
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  if setup_yarn "$@"; then
    exit 0
  fi
  exit 1
fi
