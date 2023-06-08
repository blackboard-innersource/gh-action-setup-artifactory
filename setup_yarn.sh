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
  if [ "$ARTIFACTORY_YARN_SETUP" == "false" ]; then
    echo "Skipping yarn setup because ARTIFACTORY_YARN_SETUP=$ARTIFACTORY_YARN_SETUP"
    return 0
  fi

  require_env "ARTIFACTORY_TOKEN" "$ARTIFACTORY_TOKEN" || return 1

  ARTIFACTORY_REGISTRY="https://blackboard.jfrog.io/artifactory/api/npm/fnds-npm/"

  if [[ -d "$PWD/.yarn/releases" ]]; then
    echo "Yarn 2+ was detected"

    # https://yarnpkg.com/cli/config/set
    yarn config set -H npmAlwaysAuth "true"
    yarn config set -H npmAuthToken "$ARTIFACTORY_TOKEN"
    yarn config set -H npmRegistryServer "$ARTIFACTORY_REGISTRY"
  else
    echo "Yarn 1 was detected"

    local yarnrc
    yarnrc="$HOME/.yarnrc"
    cat > "$yarnrc" << EOF
registry=$ARTIFACTORY_REGISTRY
$ARTIFACTORY_REGISTRY:_authToken="${ARTIFACTORY_TOKEN}"
$ARTIFACTORY_REGISTRY:always-auth="true"
EOF

    echo "Wrote to $yarnrc"
  fi

  return 0
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  if setup_yarn "$@"; then
    exit 0
  fi
  exit 1
fi
