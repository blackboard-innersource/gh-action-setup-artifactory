#!/usr/bin/env bash

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

add_text_to_xml() {
  for array in "${settings_arrays[@]}";do
    IFS=", " read -r -a settings_values <<< $array
    case ${1} in
      "server_text")
      echo "\
      <server>
         <username>$ARTIFACTORY_USERNAME</username>
         <password>$ARTIFACTORY_TOKEN</password>
         <id>${settings_values[1]}</id>
      </server>"
      ;;
      "repository_text")
      echo "\
      <repository>
          <snapshots>
            <enabled>${settings_values[3]}</enabled>
          </snapshots>
          <id>${settings_values[1]}</id>
          <name>${settings_values[0]}</name>
          <url>${url_prefix}${settings_values[2]}</url>
      </repository>"
      ;;
      "plugins_text")
      echo "\
      <pluginRepository>
          <snapshots>
            <enabled>${settings_values[3]}</enabled>
          </snapshots>
          <id>${settings_values[1]}</id>
          <name>${settings_values[0]}</name>
          <url>${url_prefix}${settings_values[2]}</url>
      </pluginRepository>"
      ;;
    esac
  done
}

setup_mvn() {
  if [ "$ARTIFACTORY_SETUP_MVN" == "false" ]; then
    echo "Skipping Settings.xml setup because ARTIFACTORY_SETUP_MVN=$ARTIFACTORY_SETUP_MVN"
    return 0
  fi

  require_env "ARTIFACTORY_USERNAME" "$ARTIFACTORY_USERNAME" || return 1
  require_env "ARTIFACTORY_TOKEN" "$ARTIFACTORY_TOKEN" || return 1

  url_prefix="${ARTIFACTORY_MVN_URL:-https://blackboard.jfrog.io/artifactory/}"
  if [[ ${ARTIFACTORY_MVN_DEFAULT} != "false" ]];then
    settings_arrays=("fnds-maven,central,fnds-maven,false" "fnds-maven,snapshots,fnds-maven,false")
  else
    settings_arrays=()
    prefix=ARTIFACTORY_MVN_REPOS_
    env_var_names=$(compgen -A variable | grep $prefix)
    for env_var_name in $env_var_names;do
      eval env_var_valus='$'$env_var_name
      settings_arrays[${#settings_arrays[@]}]=$env_var_valus
    done
  fi

  local settings_xml
  local mvn_path
  mvn_path="$HOME/.m2"
  settings_xml="${mvn_path}/settings.xml"

  if [[ ! -d "${mvn_path}" ]];then
    mkdir ${mvn_path}
  fi

  cat > $settings_xml << EOF
<settings xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 http://maven.apache.org/xsd/settings-1.2.0.xsd" xmlns="http://maven.apache.org/SETTINGS/1.2.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <servers>
  $(add_text_to_xml "server_text")
  </servers>
  <profiles>
    <profile>
      <repositories>
        $(add_text_to_xml "repository_text")
      </repositories>
      <pluginRepositories>
        $(add_text_to_xml "plugins_text")
      </pluginRepositories>
      <id>artifactory</id>
    </profile>
  </profiles>
  <activeProfiles>
    <activeProfile>artifactory</activeProfile>
  </activeProfiles>
</settings>

EOF

  echo "Wrote to $settings_xml"

  return 0
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  if setup_mvn "$@"; then
    exit 0
  fi
  exit 1
fi
