#!/usr/bin/env bash

set -e

dir=$(dirname "${BASH_SOURCE[0]}")

. "$dir/setup_pip.sh"
. "$dir/setup_npm.sh"
. "$dir/setup_yarn.sh"
. "$dir/setup_mvn.sh"
. "$dir/setup_sbt.sh"

setup_pip
setup_npm
setup_yarn
setup_mvn
setup_sbt

if [ "$ARTIFACTORY_SETUP_JFROG" == "true" ]; then
  . "$dir/setup_jfrog.sh"
  setup_jfrog
else
  echo "Skipping jf setup because ARTIFACTORY_SETUP_JFROG!=true"
fi