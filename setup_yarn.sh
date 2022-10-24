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
  if [ "$ARTIFACTORY_YARN_ID_TOKEN" == "false" ]; then
    echo "Skipping yarn setup because ARTIFACTORY_YARN_ID_TOKEN=$ARTIFACTORY_YARN_ID_TOKEN"
    return 0
  fi

  require_env "ARTIFACTORY_YARN_ID_TOKEN" "$ARTIFACTORY_YARN_ID_TOKEN" || return 1

  local yarnrc
  yarnrc="$HOME/.yarnrc.yml"
  cat > "$yarnrc" << EOF
npmAlwaysAuth: true
npmAuthToken: ${ARTIFACTORY_YARN_ID_TOKEN}

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
