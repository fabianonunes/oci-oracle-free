#!/bin/bash
# Since: April, 2023
# Author: gvenzl
# Name: all-container-tests.sh
# Description: Script for all run tests for Oracle DB Free
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

source ./functions.sh

./test-container.sh "gvenzl/oracle-free:23.7-full-faststart-$(getArch)"
./test-container.sh "gvenzl/oracle-free:23.7-faststart-$(getArch)"
./test-container.sh "gvenzl/oracle-free:23.7-slim-faststart-$(getArch)"

./test-container.sh "gvenzl/oracle-free:23.7-full-$(getArch)"
./test-container.sh "gvenzl/oracle-free:23.7-$(getArch)"
./test-container.sh "gvenzl/oracle-free:23.7-slim-$(getArch)"

#./test-container.sh "gvenzl/oracle-free:23.6-full-faststart-$(getArch)"
#./test-container.sh "gvenzl/oracle-free:23.6-faststart-$(getArch)"
#./test-container.sh "gvenzl/oracle-free:23.6-slim-faststart-$(getArch)"

#./test-container.sh "gvenzl/oracle-free:23.6-full-$(getArch)"
#./test-container.sh "gvenzl/oracle-free:23.6-$(getArch)"
#./test-container.sh "gvenzl/oracle-free:23.6-slim-$(getArch)"

#./test-container.sh "gvenzl/oracle-free:23.5-full-faststart-$(getArch)"
#./test-container.sh "gvenzl/oracle-free:23.5-faststart-$(getArch)"
#./test-container.sh "gvenzl/oracle-free:23.5-slim-faststart-$(getArch)"

#./test-container.sh "gvenzl/oracle-free:23.5-full-$(getArch)"
#./test-container.sh "gvenzl/oracle-free:23.5-$(getArch)"
#./test-container.sh "gvenzl/oracle-free:23.5-slim-$(getArch)"

#./test-container.sh "gvenzl/oracle-free:23.4-full-faststart"
#./test-container.sh "gvenzl/oracle-free:23.4-faststart"
#./test-container.sh "gvenzl/oracle-free:23.4-slim-faststart"

#./test-container.sh "gvenzl/oracle-free:23.4-full"
#./test-container.sh "gvenzl/oracle-free:23.4"
#./test-container.sh "gvenzl/oracle-free:23.4-slim"

#./test-container.sh "gvenzl/oracle-free:23.3-full-faststart"
#./test-container.sh "gvenzl/oracle-free:23.3-faststart"
#./test-container.sh "gvenzl/oracle-free:23.3-slim-faststart"

#./test-container.sh "gvenzl/oracle-free:23.3-full"
#./test-container.sh "gvenzl/oracle-free:23.3"
#./test-container.sh "gvenzl/oracle-free:23.3-slim"

#./test-container.sh "gvenzl/oracle-free:23.2-full-faststart"
#./test-container.sh "gvenzl/oracle-free:23.2-faststart"
#./test-container.sh "gvenzl/oracle-free:23.2-slim-faststart"

#./test-container.sh "gvenzl/oracle-free:23.2-full"
#./test-container.sh "gvenzl/oracle-free:23.2"
#./test-container.sh "gvenzl/oracle-free:23.2-slim"
