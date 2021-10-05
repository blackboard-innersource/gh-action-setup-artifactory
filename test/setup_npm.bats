#!/usr/bin/env bats

load "setup_npm.sh"
load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"

TMPDIR=""

function setup {
  TMPDIR=$(mktemp -d)
}

function teardown {
  if [ -d "$TMPDIR" ]; then
    rm -rf "$TMPDIR"
  fi
}

# shellcheck disable=SC2034
@test "setup_npm can configure npm" {
  HOME="$TMPDIR"
  ARTIFACTORY_USERNAME="test_username"
  ARTIFACTORY_TOKEN="test_token"
  ARTIFACTORY_NPM_REGISTRY="https://example.com/test_registry/"

  run setup_npm
  assert_success
  assert [ -f "$TMPDIR/.npmrc" ]

  run cat "$TMPDIR/.npmrc"
  assert_success
  assert_output - <<EOF
registry=https://example.com/test_registry/
//example.com/test_registry/:_password=dGVzdF90b2tlbg==
//example.com/test_registry/:username=test_username
//example.com/test_registry/:always-auth=true
EOF

}

# shellcheck disable=SC2034
@test "setup_npm can configure npm with scopes" {
  HOME="$TMPDIR"
  ARTIFACTORY_USERNAME="test_username"
  ARTIFACTORY_TOKEN="test_token"
  ARTIFACTORY_NPM_REGISTRY="https://example.com/test_registry/"
  ARTIFACTORY_NPM_SCOPES="@acme,@wakka"

  run setup_npm
  assert_success
  assert [ -f "$TMPDIR/.npmrc" ]

  run cat "$TMPDIR/.npmrc"
  assert_success
  assert_output - <<EOF
@acme:registry=https://example.com/test_registry/
@wakka:registry=https://example.com/test_registry/
//example.com/test_registry/:_password=dGVzdF90b2tlbg==
//example.com/test_registry/:username=test_username
//example.com/test_registry/:always-auth=true
EOF

}

# shellcheck disable=SC2034
@test "setup_npm can be disabled" {
  HOME="$TMPDIR"
  ARTIFACTORY_SETUP_NPM="false"

  run setup_npm
  assert_success
  assert [ ! -f "$TMPDIR/.npmrc" ]
  assert_output "Skipping npm setup because ARTIFACTORY_SETUP_NPM=false"
}

# shellcheck disable=SC2034
@test "setup_npm fails when missing env var" {
  HOME="$TMPDIR"

  run setup_npm
  assert_failure
  assert [ ! -f "$TMPDIR/.npmrc" ]
  assert_output "Missing env var 'ARTIFACTORY_USERNAME'"
}

# base64 on Linux wraps at 76 characters
@test "encode long string that does not wrap" {
  run encode "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  assert_success
  assert_output "eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4"
}

