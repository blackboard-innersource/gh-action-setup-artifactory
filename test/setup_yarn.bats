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
    echo "$TMPDIR"
  fi
}

# shellcheck disable=SC2034
@test "setup_yarn can configure yarnrc.yml" {
  HOME="$TMPDIR"
  ARTIFACTORY_TOKEN="test_token"

  mkdir -p $TMPDIR/project/.yarn/releases

  touch $TMPDIR/.yarnrc.yml
  touch $TMPDIR/project/.yarnrc.yml

  pushd $TMPDIR/project

  yarn set version berry

  run setup_yarn
  assert_success

  popd

  assert [ ! -f "$TMPDIR/.yarnrc" ]
  assert [ ! -f "$TMPDIR/project/.yarnrc" ]

  assert [ -f "$TMPDIR/.yarnrc.yml" ]
  assert [ -f "$TMPDIR/project/.yarnrc.yml" ]

  run cat "$TMPDIR/project/.yarnrc.yml"
  assert_success

  run cat "$TMPDIR/.yarnrc.yml"
  assert_success
  assert_output - <<EOF
npmAlwaysAuth: true

npmAuthToken: test_token

npmRegistryServer: "https://blackboard.jfrog.io/artifactory/api/npm/fnds-npm/"
EOF

}

# shellcheck disable=SC2034
@test "setup_yarn can configure .yarnrc" {
  HOME="$TMPDIR"
  ARTIFACTORY_TOKEN="test_token"

  mkdir -p $TMPDIR/project

  touch $TMPDIR/.yarnrc
  touch $TMPDIR/project/.yarnrc

  pushd $TMPDIR/project

  run setup_yarn
  assert_success

  popd

  assert [ ! -f "$TMPDIR/.yarnrc.yml" ]
  assert [ -f "$TMPDIR/.yarnrc" ]

  run cat "$TMPDIR/.yarnrc"
  assert_success
  assert_output - <<EOF
registry=https://blackboard.jfrog.io/artifactory/api/npm/fnds-npm/
https://blackboard.jfrog.io/artifactory/api/npm/fnds-npm/:_authToken="test_token"
https://blackboard.jfrog.io/artifactory/api/npm/fnds-npm/:always-auth="true"
EOF

}

# shellcheck disable=SC2034
@test "setup_yarn can be disabled" {
  HOME="$TMPDIR"
  ARTIFACTORY_YARN_SETUP="false"

  run setup_yarn
  assert_success
  assert [ ! -f "$TMPDIR/.yarnrc" ]
  assert [ ! -f "$TMPDIR/.yarnrc.yml" ]
  assert_output "Skipping yarn setup because ARTIFACTORY_YARN_SETUP=false"
}

# shellcheck disable=SC2034
@test "setup_yarn fails when missing env var" {
  HOME="$TMPDIR"
  unset ARTIFACTORY_TOKEN

  run setup_yarn
  assert_failure
  assert [ ! -f "$TMPDIR/.yarnrc" ]
  assert [ ! -f "$TMPDIR/.yarnrc.yml" ]
}
