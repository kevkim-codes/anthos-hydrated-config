#!/usr/bin/env bash

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "### "
echo "### Begin Full install"
echo "### "
source ./1-settings.env
./2-tools-install.sh
./3-provision-gke.sh
./4-policy-management-install.sh
./7-istio-install-control.sh
./5-provision-kops-gce.sh
./6-provision-hub-reqs.sh
#sleep 30
#./7.1-istio-multicluster-install-remote.sh
#./7.2-istio-multicluster-connect-clusters.sh
#./7.3-istio-multicluster-firewall.sh

# ./8-service-mesh-enable.sh
