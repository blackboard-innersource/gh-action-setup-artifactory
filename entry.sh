#!/usr/bin/env bash

set -e

dir=$(dirname "${BASH_SOURCE[0]}")

# Helper function to time operations
time_operation() {
    local start=$(date +%s.%N)
    "$@"
    local end=$(date +%s.%N)
    local duration=$(echo "$end - $start" | bc)
    printf "%-20s took %.2f seconds\n" "$1" "$duration"
}

# Source all setup scripts
. "$dir/setup_pip.sh"
. "$dir/setup_npm.sh"
. "$dir/setup_yarn.sh"
. "$dir/setup_mvn.sh"
. "$dir/setup_sbt.sh"

# Execute and time each setup
time_operation setup_pip
time_operation setup_npm
time_operation setup_yarn
time_operation setup_mvn
time_operation setup_sbt

if [ "$ARTIFACTORY_SETUP_JFROG" == "true" ]; then
    . "$dir/setup_jfrog.sh"
    time_operation setup_jfrog
else
    echo "Skipping jf setup because ARTIFACTORY_SETUP_JFROG!=true"
fi