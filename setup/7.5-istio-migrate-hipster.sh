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
echo "### Migrate all hipster to central cluster"
echo "### "

# Set vars for DIRs
export WORK_DIR=$HOME/anthos-demo
export ISTIO_DIR=$WORK_DIR/setup/resources/istio

# Install all of the deployments, services and necessary serviceentries on central cluster
# The following folder contains 
# - All of the deployments for hipster app
# - Correct ENV values for deployments to point to vaious microservices
# - All of the services for hipster app
# - A service entry required for currency service to function

kubectx central
kubectl apply -n hipster2  -f ${ISTIO_DIR}/hipster 
kubectl delete -n hipster2 -f ${ISTIO_DIR}/central/service-entries.yaml
