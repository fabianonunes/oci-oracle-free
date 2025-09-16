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
   -o: passes on container build option

* select only one image flavor: -f, -r, or -s

Apache License, Version 2.0

Copyright (c) 2024 Gerald Venzl

EOF

}

while getopts "hfrsv:o:" optname; do
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
