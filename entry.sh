#!/usr/bin/env bash

set -e

dir=$(dirname "${BASH_SOURCE[0]}")
"$dir/setup_pip.sh"
"$dir/setup_npm.sh"
"$dir/setup_yarn.sh"
"$dir/setup_mvn.sh"

# Only attempt to automatically configure JFrog if we have the Artifactory URL
if [ -n "$ARTIFACTORY_URL" ]; then
  "$dir/setup_jfrog.sh"
fi
