#!/usr/bin/env bash

# EXPERIMENTAL: this script is primarily for installing jfrog CLI in CodeBuild For GitHub Actions,
# https://github.com/jfrog/setup-jfrog-cli is more stable, but this script does try to verify checksums.

# Highly customized version of https://install-cli.jfrog.io - primarily refer back to this script to see all the
# different download URL options.

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

# Map operating system to what JFrog named the operating system in their download URL
get_os() {
  local os
  os=$(uname | tr '[:upper:]' '[:lower:]')
  case "$os" in
      linux) os="linux";;
      *) >&2 echo "OS ${os} is not supported by this installation script"; return 1;;
  esac

  echo "$os"
  return 0
}

# Map arch to what JFrog named the arch in their download URL
get_arch() {
  local machineType arch
  machineType="$(uname -m)"
  case $machineType in
      i386 | i486 | i586 | i686 | i786 | x86) arch="386";;
      amd64 | x86_64 | x64) arch="amd64";;
      arm | armv7l) arch="arm";;
      aarch64) arch="arm64";;
      *) >&2 echo "Unknown machine type (arch): $machineType"; return 1;;
  esac

  echo "$arch"
  return 0
}

# If you upgrade jf, then run tests to get updated checksums
get_checksum() {
    local cs
    case "$1" in
        linux_amd64) cs="5b39866e79a35ca4bc87dabaae6360cbbf9b224f9a97672998dbfc655faeb594";;
        linux_arm64) cs="4415dbee89260d29d51b123dbcf6e608c29d5c2e05df00f644944645bbfbc0ad";;
        *) >&2 echo "No checksum defined for ${1}"; return 1;;
    esac

    echo "$cs  jf"
    return 0
}

install_binary() {
  local dest dests

  dests=("/usr/local/bin" "/usr/bin" "/opt/bin")

  for dest in "${dests[@]}"; do
    # This if is testing if our destination is in the $PATH (start, middle, end)
    if [[ "$PATH" == "${dest}:"*  ]] || [[ "$PATH" == *":${dest}:"*  ]] || [[ "$PATH" == *":${dest}"  ]]; then
      if ! install --mode +x "$1" "$dest"; then
        >&2 echo "Failed to install ${1} to ${dest}"
        return 1
      fi
      echo "Installed ${1} to ${dest}"
      jf --version || return 1
      return 0
    fi
  done

  >&2 echo "Failed to install ${1}; None of these paths appear in \$PATH:" "${dests[@]}" "and \$PATH=${PATH}"
  return 1
}

config_jf() {
  require_env "ARTIFACTORY_URL" "$ARTIFACTORY_URL" || return 1
  require_env "ARTIFACTORY_USERNAME" "$ARTIFACTORY_USERNAME" || return 1
  require_env "ARTIFACTORY_TOKEN" "$ARTIFACTORY_TOKEN" || return 1

  echo "Configure JFrog server"
  CI=true jf config add default --url "$ARTIFACTORY_URL" --user "$ARTIFACTORY_USERNAME" --access-token "$ARTIFACTORY_TOKEN" || return 1

  echo -n "Ping JFrog server: "
  jf rt ping || return 1
}

setup_jfrog() {
  local version majorVersion os arch checksum url

  # If you update versions, then run tests to update checksums
  version="2.33.0"
  majorVersion="v2-jf"
  os=$(get_os)
  arch=$(get_arch)

  require_var "$os" "Failed to determine OS" || return 1
  require_var "$arch" "Failed to determine machine architecture" || return 1

  checksum=$(get_checksum "${os}_${arch}")
  url="https://releases.jfrog.io/artifactory/jfrog-cli/${majorVersion}/${version}/jfrog-cli-${os}-${arch}/jf"

  echo "Downloading: ${url}"

  # --globoff is here if we ever allow "[RELEASE]" for the version (downloads latest)
  # --location allows for redirects
  # --silent --show-error disables process meter but still prints errors
  if ! curl --globoff --location --silent --show-error --output jf "$url"; then
    >&2 echo "Failed to download the jf binary"
    return 1
  fi

  if [[ ! -f "jf" ]]; then
    >&2 echo "Failed find the jf binary in current working directory"
    return 1
  fi

  echo "Verifying checksum of jf"
  if ! echo "${checksum}" | sha256sum -c; then
    >&2 echo "Failed to verify checksum."
    >&2 echo "Expected: ${checksum}"
    >&2 echo "Got:      $(sha256sum jf)"
    return 1
  fi

  if ! install_binary "jf"; then
    >&2 echo "Failed to install jf";
   return 1
  fi

  # Allow for install only and no config
  if [ -z "$ARTIFACTORY_URL" ]; then
    echo "Skipping configuring jf because ARTIFACTORY_URL env var is empty"
    return 0
  fi

  if ! config_jf; then
    >&2 echo "Failed to configure jf"
    return 1
  fi
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  if setup_jfrog "$@"; then
    exit 0
  fi
  exit 1
fi
