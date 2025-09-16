#!/bin/bash
#
# Since: April, 2023
# Author: gvenzl
# Name: buildContainerImage.sh
# Description: Build a Container image for Oracle Database Free
#
# Copyright 2023 Gerald Venzl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Exit on errors
# Great explanation on https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

VERSION="23.8"
IMAGE_FLAVOR="REGULAR"
IMAGE_NAME="gvenzl/oracle-free"
SKIP_CHECKSUM="false"
BASE_IMAGE=""
DB_FLAVOR="ai"
BUILDER_ARCH=$(uname -m)

function usage() {
    cat << EOF

Usage: buildContainerImage.sh [-f | -r | -s] [-x] [-v version] [-i] [-o] [container build option]
Builds a container image for Oracle Database Free.

Parameters:
   -f: creates a 'full' image
   -r: creates a regular image (default)
   -s: creates a 'slim' image
   -v: version of Oracle Database Free to build
       Choose one of: 23.8, 23.7, 23.6, 23.5, 23.4, 23.3, 23.2
   -i: ignores checksum test
   -o: passes on container build option

* select only one image flavor: -f, -r, or -s

Apache License, Version 2.0

Copyright (c) 2024 Gerald Venzl

EOF

}

while getopts "hfrsv:io:x" optname; do
  case "${optname}" in
    "h")
      usage
      exit 0;
      ;;
    "v")
      VERSION="${OPTARG}"
      # 23.2 and 23.3 are called 23c not 23ai
      if [[ ("${VERSION}" == "23.2") || ("${VERSION}" == "23.3") ]]; then
        DB_FLAVOR="c"
      fi;
      ;;
    "f")
      IMAGE_FLAVOR="FULL"
      ;;
    "r")
      IMAGE_FLAVOR="REGULAR"
      ;;
    "s")
      IMAGE_FLAVOR="SLIM"
      ;;
    "i")
      SKIP_CHECKSUM="true"
      ;;
    "o")
      eval "BUILD_OPTS=(${OPTARG})"
      ;;
    "?")
      usage;
      exit 1;
      ;;
    *)
    # Should not occur
      echo "Unknown error while processing options inside buildContainerImage.sh"
      ;;
  esac;
done;

# Checking SHASUM
if [ "${SKIP_CHECKSUM}" == "false" ]; then

  echo "BUILDER: verifying checksum of rpm file - please wait..."

  SHASUM_RET=$(sha256sum oracle*free*"${VERSION}"*.rpm)

  if [[ ( "${VERSION}" == "23.2"  &&                                                                        "${SHASUM_RET%% *}" != "63b6c0ec9464682cfd9814e7e2a5d533139e5c6aeb9d3e7997a5f976d6677ca6" ) ||
        ( "${VERSION}" == "23.3"  &&                                                                        "${SHASUM_RET%% *}" != "1319bcd7cb706cb727501cbd98abf3f3980a4fdabeb613a1abffc756925c7374" ) ||
        ( "${VERSION}" == "23.4"  &&                                                                        "${SHASUM_RET%% *}" != "e6cccec7f101325c233f374c2aa86f77d62123edd3125450d79404c3eec30b65" ) ||
        ( "${VERSION}" == "23.5"  &&    "${BUILDER_ARCH}" == "x86_64"  &&                                   "${SHASUM_RET%% *}" != "80c1ceae3b158cffe71fa4cfa8e4f540161659f79f777bcf48935f79031c054c" ) ||
        ( "${VERSION}" == "23.5"  &&  ( "${BUILDER_ARCH}" == "aarch64" || "${BUILDER_ARCH}" == "arm64" ) && "${SHASUM_RET%% *}" != "9f82f22217db7c760d25956ca1590be996dbbe1ea397949726c68065524f69af" ) ||
        ( "${VERSION}" == "23.6"  &&    "${BUILDER_ARCH}" == "x86_64"  &&                                   "${SHASUM_RET%% *}" != "03ae958784e9443c0380e4d387cb0522016c72d029ab85cf55ee124489833e0e" ) ||
        ( "${VERSION}" == "23.6"  &&  ( "${BUILDER_ARCH}" == "aarch64" || "${BUILDER_ARCH}" == "arm64" ) && "${SHASUM_RET%% *}" != "64b84cdbd3331a4fee7a7bf56cdfd497a2531b05862bddae0f38e28c745dc8d6" ) ||
        ( "${VERSION}" == "23.7"  &&    "${BUILDER_ARCH}" == "x86_64"  &&                                   "${SHASUM_RET%% *}" != "af64450e1120e56dac43a447a2e109449c7590489003d830d6a32a9168e0469d" ) ||
        ( "${VERSION}" == "23.7"  &&  ( "${BUILDER_ARCH}" == "aarch64" || "${BUILDER_ARCH}" == "arm64" ) && "${SHASUM_RET%% *}" != "b069d02c624ed63aa8bbdb0a6ae884e1b0fc8d60b315adedc0e781dea0607d2a" ) ||
        ( "${VERSION}" == "23.8"  &&    "${BUILDER_ARCH}" == "x86_64"  &&                                   "${SHASUM_RET%% *}" != "cd0d16939150e6ec5e70999a762a13687bfa99b05c4f310593e7ca3892e1d0ce" ) ||
        ( "${VERSION}" == "23.8"  &&  ( "${BUILDER_ARCH}" == "aarch64" || "${BUILDER_ARCH}" == "arm64" ) && "${SHASUM_RET%% *}" != "c5cdd5d3b7017594899e8f13eb2d69f2ae6339ec3a78e647f18800ad7dc44346" ) ||
        ( "${VERSION}" == "23.9"  &&    "${BUILDER_ARCH}" == "x86_64"  &&                                   "${SHASUM_RET%% *}" != "a6e64941ad940dd23e152e3d51213aeaea6d93b43688fbd030175935e0efe03d" ) ||
        ( "${VERSION}" == "23.9"  &&  ( "${BUILDER_ARCH}" == "aarch64" || "${BUILDER_ARCH}" == "arm64" ) && "${SHASUM_RET%% *}" != "59faac204495cc6a08b6e99cd0997226c17fe4d7362e16b73ae5446b3e5b688e" )
      ]]; then
    echo "BUILDER: WARNING! SHA sum of RPM does not match with what's expected!"
    echo "BUILDER: WARNING! Verify that the .rpm file is not corrupt!"
  fi;

  echo "BUILDER: checksum verification done"
else
  echo "BUILDER: checksum verification ignored"
fi;

# Set Dockerfile name
DOCKER_FILE="Dockerfile.${VERSION%??}"

# Give image base tag
IMAGE_NAME="${IMAGE_NAME}:${VERSION}"

# Add image flavor to the tag (regular has no tag)
if [ "${IMAGE_FLAVOR}" != "REGULAR" ]; then
  IMAGE_NAME="${IMAGE_NAME}-${IMAGE_FLAVOR,,}"
fi;

# Decide on the architecture
if [ "${BUILDER_ARCH}" == "x86_64" ]; then
  ARCH="amd64"
  RPM_ARCH="x86_64"
# Could be reported as 'aarch64' or 'arm64' (ubuntu, etc.)
else
  ARCH="arm64"
  RPM_ARCH="aarch64"
fi;

IMAGE_NAME="${IMAGE_NAME}-${ARCH}"

echo "BUILDER: building image $IMAGE_NAME"

BUILD_START_TMS=$(date '+%s')

docker build \
  -f "$DOCKER_FILE" \
  -t "${IMAGE_NAME}" \
  --platform "linux/${ARCH}" \
  --build-arg BUILDKIT_SANDBOX_HOSTNAME="localhost" \
  --build-arg BUILD_MODE="${IMAGE_FLAVOR}" \
  --build-arg BASE_IMAGE="${BASE_IMAGE}" \
  --build-arg BUILD_VERSION="${VERSION}" \
  --build-arg DB_FLAVOR="${DB_FLAVOR}" \
  --build-arg ARCH="${ARCH}" \
  --build-arg RPM_ARCH="${RPM_ARCH}" \
  --progress=plain .

BUILD_END_TMS=$(date '+%s')
BUILD_DURATION=$(( BUILD_END_TMS - BUILD_START_TMS ))

echo "Build of container image ${IMAGE_NAME} completed in ${BUILD_DURATION} seconds."
