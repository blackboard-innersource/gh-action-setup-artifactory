#!/usr/bin/env bash

set -e

dir=$(dirname "${BASH_SOURCE[0]}")
"$dir/setup_pip.sh"
"$dir/setup_npm.sh"
"$dir/setup_yarn.sh"