#!/usr/bin/env bats

load "setup_pip.sh"
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
@test "setup_pip can configure pip" {
  HOME="$TMPDIR"
  XDG_CONFIG_HOME="$TMPDIR/.config"
  ARTIFACTORY_USERNAME="test_username"
  ARTIFACTORY_TOKEN="test_token"
  ARTIFACTORY_PYPI_INDEX="https://example.com/test_index"

  run setup_pip
  assert_success
  assert [ -f "$TMPDIR/.config/pip/pip.conf" ]
  assert [ -f "$TMPDIR/.netrc" ]

  run cat "$TMPDIR/.config/pip/pip.conf"
  assert_success
  assert_output - <<EOF
[global]
index-url = https://example.com/test_index
EOF

  run cat "$TMPDIR/.netrc"
  assert_success
  assert_output - <<EOF
machine example.com
login test_username
password test_token
EOF
}

# shellcheck disable=SC2034
@test "setup_pip can configure pip without index URL" {
  HOME="$TMPDIR"
  XDG_CONFIG_HOME="$TMPDIR/.config"
  ARTIFACTORY_USERNAME="test_username"
  ARTIFACTORY_TOKEN="test_token"

  run setup_pip
  assert_success
  assert [ -f "$TMPDIR/.config/pip/pip.conf" ]
  assert [ -f "$TMPDIR/.netrc" ]

  run cat "$TMPDIR/.config/pip/pip.conf"
  assert_success
  assert_output - <<EOF
[global]
index-url = https://blackboard.jfrog.io/artifactory/api/pypi/fnds-pypi/simple
EOF

  run cat "$TMPDIR/.netrc"
  assert_success
  assert_output - <<EOF
machine blackboard.jfrog.io
login test_username
password test_token
EOF
}

# shellcheck disable=SC2034
@test "setup_pip can be disabled" {
  HOME="$TMPDIR"
  XDG_CONFIG_HOME="$TMPDIR/.config"
  ARTIFACTORY_SETUP_PIP="false"

  run setup_pip
  assert_success
  assert [ ! -f "$TMPDIR/.config/pip/pip.conf" ]
  assert [ ! -f "$TMPDIR/.netrc" ]
  assert_output "Skipping pip setup because ARTIFACTORY_SETUP_PIP=false"
}

# shellcheck disable=SC2034
@test "setup_pip fails when missing env var" {
  HOME="$TMPDIR"
  XDG_CONFIG_HOME="$TMPDIR/.config"

  run setup_pip
  assert_failure
  assert [ ! -f "$TMPDIR/.config/pip/pip.conf" ]
  assert [ ! -f "$TMPDIR/.netrc" ]
  assert_output "Missing env var 'ARTIFACTORY_USERNAME'"
}
