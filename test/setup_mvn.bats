#!/usr/bin/env bats

load "setup_mvn.sh"
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
@test "setup_mvn can configure mvn" {
  HOME="$TMPDIR"
  ARTIFACTORY_USERNAME="test_username"
  ARTIFACTORY_TOKEN="test_token"

  run setup_mvn
  assert_success
  assert [ -f "$TMPDIR/.m2/settings.xml" ]

  run cat "$TMPDIR/.m2/settings.xml"
  assert_success

  assert_output - <<EOF
<settings xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 http://maven.apache.org/xsd/settings-1.2.0.xsd" xmlns="http://maven.apache.org/SETTINGS/1.2.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <servers>
  <server>
         <username>test_username</username>
         <password>test_token</password>
         <id>central</id>
      </server>
<server>
         <username>test_username</username>
         <password>test_token</password>
         <id>snapshots</id>
      </server>
  </servers>
  <profiles>
    <profile>
      <repositories>
        <repository>
          <snapshots>
          <enabled>false</enabled>
         </snapshots>
          <id>central</id>
          <name>fnds-maven</name>
          <url>https://blackboard.jfrog.io/artifactory/fnds-maven</url>
      </repository>
<repository>
          <snapshots/>
          <id>snapshots</id>
          <name>fnds-maven</name>
          <url>https://blackboard.jfrog.io/artifactory/fnds-maven</url>
      </repository>
      </repositories>
      <pluginRepositories>
        <pluginRepository>
          <snapshots>
          <enabled>false</enabled>
         </snapshots>
          <id>central</id>
          <name>fnds-maven</name>
          <url>https://blackboard.jfrog.io/artifactory/fnds-maven</url>
      </pluginRepository>
<pluginRepository>
          <snapshots/>
          <id>snapshots</id>
          <name>fnds-maven</name>
          <url>https://blackboard.jfrog.io/artifactory/fnds-maven</url>
      </pluginRepository>
      </pluginRepositories>
      <id>artifactory</id>
    </profile>
  </profiles>
  <activeProfiles>
    <activeProfile>artifactory</activeProfile>
  </activeProfiles>
</settings>
EOF
}

# shellcheck disable=SC2034
@test "setup_mvn can be disabled" {
  HOME="$TMPDIR"
  ARTIFACTORY_SETUP_MVN="false"

  run setup_mvn
  assert_success
  assert [ ! -f "$TMPDIR/.m2/settings.xml" ]
  assert_output "Skipping Settings.xml setup because ARTIFACTORY_SETUP_MVN=false"
}

# shellcheck disable=SC2034
@test "setup_mvn fails when missing env var" {
  HOME="$TMPDIR"

  run setup_mvn
  assert_failure
  assert [ ! -f "$TMPDIR/.m2/settings.xml" ]
  assert_output "Missing env var 'ARTIFACTORY_USERNAME'"
}