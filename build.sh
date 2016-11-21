#!/usr/bin/env bash

set -eo pipefail


# Build dir should be the app root (and therefore the folder above us)
BUILD_DIR=${1:-}
CACHE_DIR=${2:-}
BUILD_ENV_DIR=${3:-}

OUR_DIR="$(cd "$(dirname "${0:-}")"; pwd)"
BUILDPACKS_ROOT=$OUR_DIR/buildpacks
# Env vars to be used by buildpacks



# arbitary ordering ahoy...
buildpacks=(${BUILDPACKS_ROOT}/*)
selected_buildpack=

# stop at first detected buildpack
for buildpack in "${buildpacks[@]}"; do
  buildpack_name=$("${buildpack}"/bin/detect "${BUILD_DIR}") \
    && selected_buildpack="${buildpack}" \
    && break
done


# Compile the app
if [[ -n "${selected_buildpack}" ]]; then
  echo "${buildpack_name} app detected"
else
  echo "Unable to select a buildpack"
  exit 1
fi

# Run the buildpack
"${selected_buildpack}"/bin/compile "${BUILD_DIR}" "${CACHE_DIR}" "${BUILD_ENV_DIR}"


# we then source the path created by the buildpack to allow
# us access to the NODE_PATHS etc
source "${selected_buildpack}"/export

# run .travis.yml test script if we can find it...
if [[ -f "${BUILD_DIR}/.travis.yml" ]]; then
  scripts=$(ruby -r yaml -e "puts YAML.load_file('${BUILD_DIR}/.travis.yml')['script']")
fi

if [[ $scripts ]]; then
  while read -r line; do
    echo running "$line"
    ${line}
  done <<< "$scripts"
else
  echo "no test commands to run"
fi

# run .travis.yml after test scripts if we can find it...
if [[ -f "${BUILD_DIR}/.travis.yml" ]]; then
  after_scripts=$(ruby -r yaml -e "puts YAML.load_file('${BUILD_DIR}/.travis.yml')['after_script']")
fi

if [[ $after_scripts ]]; then
  while read -r line; do
    echo running "$line"
    ${line}
  done <<< "$after_scripts"
else
  echo "no after_scripts to run"
fi
