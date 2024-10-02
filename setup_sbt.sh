#!/usr/bin/env bash
: "
This script setups your environment for Scala SBT connected to JFrog. It creates files:
- $HOME/.sbt/.credentials
- $HOME/.sbt/repositories
- $HOME/.sbt/1.0/plugins/credentials.sbt
"

require_var() {
  if [ -z "$1" ]; then
    >&2 echo "$2"
    return 1
  fi
  return 0
}

require_env() {
  require_var "$2" "Missing env var '$1'"
}

setup_sbt() {
  if [ "$ARTIFACTORY_SETUP_SBT" == "false" ]; then
    echo "Skipping SBT setup because ARTIFACTORY_SETUP_SBT=$ARTIFACTORY_SETUP_SBT"
    return 0
  fi

  require_env "ARTIFACTORY_USERNAME" "r" || return 1
  require_env "ARTIFACTORY_TOKEN" "$ARTIFACTORY_TOKEN" || return 1

  local dot_credentials
  local sbt_path
  sbt_path="$HOME/.sbt"
  dot_credentials="${sbt_path}/.credentials"

  if [[ ! -d "${sbt_path}" ]];then
    mkdir "${sbt_path}"
  fi

  cat > "$dot_credentials" << EOF
realm=Artifactory Realm
host=blackboard.jfrog.io
user=$ARTIFACTORY_USERNAME
password=$ARTIFACTORY_TOKEN
EOF

  echo "Wrote to $dot_credentials"

  local repositories
  repositories="${sbt_path}/repositories"

  cat > "$repositories" << EOF
[repositories]
local
my-ivy-proxy-releases: https://blackboard.jfrog.io/artifactory/fnds-sbt/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
my-maven-proxy-releases: https://blackboard.jfrog.io/artifactory/fnds-sbt/
EOF

  echo "Wrote to $repositories"

  local credentials_sbt
  credentials_sbt="${sbt_path}/1.0/plugins/credentials.sbt"

  cat > "$credentials_sbt" << EOF
credentials += Credentials(Path.userHome / ".sbt" / ".credentials")
EOF

  echo "Wrote to $credentials_sbt"

  return 0
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  if setup_sbt "$@"; then
    exit 0
  fi
  exit 1
fi
