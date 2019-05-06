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
# Required from external Var
#OPERATOR_YAML_LOCATION="${OPERATOR_YAML_LOCATION:OPERATOR_YAML_LOCATION env variable must be specified}"
export OPERATOR_YAML_LOCATION="https://storage.googleapis.com/nomos-release/operator-rc/nomos-operator-v0.1.15-rc.1/nomos-operator.yaml"


echo "### "
echo "### Begin install config manager"
echo "### "


## Deploy the CSP Config Management Operator
kubectl apply -f $OPERATOR_YAML_LOCATION



