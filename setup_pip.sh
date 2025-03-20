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

setup_pip() {
  if [ "$ARTIFACTORY_SETUP_PIP" == "false" ]; then
    echo "Skipping pip setup because ARTIFACTORY_SETUP_PIP=$ARTIFACTORY_SETUP_PIP"
    return 0
  fi

  require_env "ARTIFACTORY_USERNAME" "$ARTIFACTORY_USERNAME" || return 1
  require_env "ARTIFACTORY_TOKEN" "$ARTIFACTORY_TOKEN" || return 1

  local domain
  if [ -n "$ARTIFACTORY_PYPI_INDEX" ]; then
    domain=$(echo "$ARTIFACTORY_PYPI_INDEX" | awk -F '[/:]' '{print $4}')
    require_var "$domain" "Failed to extract domain from ARTIFACTORY_PYPI_INDEX env var" || return 1
  else
    ARTIFACTORY_PYPI_INDEX="https://blackboard.jfrog.io/artifactory/api/pypi/fnds-pypi/simple"
    domain="blackboard.jfrog.io"
  fi

  local netrc
  netrc="$HOME/.netrc"

  cat > "$netrc" << EOF
machine $domain
login $ARTIFACTORY_USERNAME
password $ARTIFACTORY_TOKEN

EOF

  echo "Wrote to $netrc"

  if [ -n "$GITHUB_ENV" ]; then
    echo "PIP_INDEX_URL=$ARTIFACTORY_PYPI_INDEX" >> "$GITHUB_ENV"
    echo "UV_DEFAULT_INDEX=$ARTIFACTORY_PYPI_INDEX" >> "$GITHUB_ENV"
  else
    export PIP_INDEX_URL="$ARTIFACTORY_PYPI_INDEX"
    export UV_DEFAULT_INDEX="$ARTIFACTORY_PYPI_INDEX"
  fi
  echo "Set env PIP_INDEX_URL and UV_DEFAULT_INDEX"

  return 0
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  if setup_pip "$@"; then
    exit 0
  fi
  exit 1
fi