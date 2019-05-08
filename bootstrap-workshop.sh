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

# Variables

export PROJECT=$(gcloud config get-value project)
export BASE_DIR=${BASE_DIR:="${PWD}"}
export WORK_DIR=${WORK_DIR:="${BASE_DIR}/workdir"}

echo "WORK_DIR set to $WORK_DIR"
gcloud config set project $PROJECT

source ./0-Common/settings.env
./0-Common/install-tools.sh
./1-GKE/provision-gke.sh
./1-ConnectHub/provision-remote-gce.sh
kubectx central
./2-ConfigManagement/install-config-operator.sh
kubectx remote
./2-ConfigManagement/install-config-operator.sh

./4-HybridMulticluster/istio-install.sh
