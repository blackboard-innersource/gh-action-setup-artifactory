#!/usr/bin/env bats

load "setup_sbt.sh"
load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"

TMPDIR=""

function setup {
  TMPDIR=$(mktemp -d)
  mkdir -p $TMPDIR/.sbt/1.0/plugins
}

function teardown {
  if [ -d "$TMPDIR" ]; then
    rm -rf "$TMPDIR"
  fi
}

# shellcheck disable=SC2034
@test "setup_sbt can configure sbt" {
  HOME="$TMPDIR"
  ARTIFACTORY_USERNAME="test_username"
  ARTIFACTORY_TOKEN="test_token"

  run setup_sbt
  assert_success
  assert [ -f "$TMPDIR/.sbt/.credentials" ]

  run cat "$TMPDIR/.sbt/.credentials"
  assert_success
  assert_output - <<EOF
realm=Artifactory Realm
host=blackboard.jfrog.io
user=test_username
password=test_token
EOF

  run cat "$TMPDIR/.sbt/repositories"
  assert_success
  assert_output - <<EOF
[repositories]
local
my-ivy-proxy-releases: https://blackboard.jfrog.io/artifactory/fnds-sbt/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
my-maven-proxy-releases: https://blackboard.jfrog.io/artifactory/fnds-sbt/
EOF

  run cat "$TMPDIR/.sbt/1.0/plugins/credentials.sbt"
  assert_success
  assert_output - <<EOF
credentials += Credentials(Path.userHome / ".sbt" / ".credentials")
EOF
}

# shellcheck disable=SC2034
@test "setup_sbt can be disabled" {
  HOME="$TMPDIR"
  ARTIFACTORY_SETUP_SBT="false"

  run setup_sbt
  assert_success
  assert [ ! -f "$TMPDIR/.sbt/.credentials" ]
  assert [ ! -f "$TMPDIR/.sbt/repositories" ]
  assert [ ! -f "$TMPDIR/.sbt/1.0/plugins/credentials.sbt" ]
  assert_output "Skipping SBT setup because ARTIFACTORY_SETUP_SBT=false"
}

# shellcheck disable=SC2034
@test "setup_sbt fails when missing env var" {
  HOME="$TMPDIR"
  run setup_sbt
  assert_failure
  assert [ ! -f "$TMPDIR/.sbt/credentials" ]
  assert [ ! -f "$TMPDIR/.sbt/repositories" ]
  assert [ ! -f "$TMPDIR/.sbt/1.0/plugins/credentials.sbt" ]
  assert_output "Missing env var 'ARTIFACTORY_TOKEN'"
}

