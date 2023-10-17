#!/usr/bin/env bats

load "setup_yarn.sh"
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
@test "setup_yarn can configure yarnrc.yml" {
  HOME="$TMPDIR"
  ARTIFACTORY_USERNAME="test_username"
  ARTIFACTORY_TOKEN="test_token"

  run setup_yarn
  assert_success
  assert [ -f "$TMPDIR/.yarnrc.yml" ]

  run cat "$TMPDIR/.yarnrc.yml"
  assert_success
  assert_output - <<EOF
npmAlwaysAuth: true
npmAuthToken: test_username:test_token
EOF

}

# shellcheck disable=SC2034
@test "setup_yarn can be disabled" {
  HOME="$TMPDIR"
  ARTIFACTORY_SETUP_YARN="false"

  run setup_yarn
  assert_success
  assert [ ! -f "$TMPDIR/.yarnrc.yml" ]
  assert_output "Skipping yarn setup because ARTIFACTORY_SETUP_YARN=false"
}

# shellcheck disable=SC2034
@test "setup_yarn can be disabled legacy" {
  HOME="$TMPDIR"
  ARTIFACTORY_YARN_SETUP="false"

  run setup_yarn
  assert_success
  assert [ ! -f "$TMPDIR/.yarnrc.yml" ]
  assert_output "Skipping yarn setup because ARTIFACTORY_YARN_SETUP=false"
}

# shellcheck disable=SC2034
@test "setup_yarn fails when missing env var" {
  HOME="$TMPDIR"

  run setup_yarn
  assert_failure
  assert [ ! -f "$TMPDIR/.yarnrc.yml" ]
  assert_output "Missing env var 'ARTIFACTORY_USERNAME'"
}
