#!/usr/bin/env bats

load "setup_jfrog.sh"
load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"

function teardown {
  if [ -f "jf" ]; then
    rm "jf"
  fi
}

# shellcheck disable=SC2034
@test "setup_jfrog can download linux amd64" {
  ARTIFACTORY_SETUP_JFROG="true"
  ARTIFACTORY_JFROG_TEST="true"

  get_os() { echo "linux"; }
  export -f get_os

  get_arch() { echo "amd64"; }
  export -f get_arch

  install_binary() { return 0; }
  export -f install_binary

  config_jf() { return 1; }
  export -f config_jf

  run setup_jfrog
  assert_success
  refute_output --partial "Failed to verify checksum"
}

# shellcheck disable=SC2034
@test "setup_jfrog can download linux arm64" {
  ARTIFACTORY_SETUP_JFROG="true"
  ARTIFACTORY_JFROG_TEST="true"

  get_os() { echo "linux"; }
  export -f get_os

  get_arch() { echo "arm64"; }
  export -f get_arch

  install_binary() { return 0; }
  export -f install_binary

  config_jf() { return 1; }
  export -f config_jf

  run setup_jfrog
  assert_success
  refute_output --partial "Failed to verify checksum"
}

# shellcheck disable=SC2034
@test "get_checksum fails for missing" {
  run get_checksum "not_real"
  assert_failure
  assert_output "No checksum defined for not_real"
}

# shellcheck disable=SC2034
@test "setup_jfrog is disabled by default" {
  ARTIFACTORY_JFROG_TEST="true"

  config_jf() { return 1; }
  export -f config_jf

  run setup_jfrog
  assert_success
  assert_output "Skipping jf setup because ARTIFACTORY_SETUP_JFROG="
}

# shellcheck disable=SC2034
@test "setup_jfrog can be disabled" {
  ARTIFACTORY_SETUP_JFROG="false"
  ARTIFACTORY_JFROG_TEST="true"

  config_jf() { return 1; }
  export -f config_jf

  run setup_jfrog
  assert_success
  assert_output "Skipping jf setup because ARTIFACTORY_SETUP_JFROG=false"
}
