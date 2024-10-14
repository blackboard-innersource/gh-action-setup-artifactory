#!/usr/bin/env bash

set -e

dir=$(dirname "${BASH_SOURCE[0]}")
"$dir/setup_pip.sh"
"$dir/setup_npm.sh"
"$dir/setup_yarn.sh"
"$dir/setup_mvn.sh"
"$dir/setup_sbt.sh"

# In general, folks do not need to setup JFrog CLI and it's slow to setup - so only do so on request
if [ "$ARTIFACTORY_SETUP_JFROG" == "true" ]; then
  "$dir/setup_jfrog.sh"
else
  echo "Skipping jf setup because ARTIFACTORY_SETUP_JFROG!=true"
fi
