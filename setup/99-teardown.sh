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

source 1-settings.env

gcloud compute firewall-rules delete istio-multicluster-test-pods -q 

./99-1-cleanup-clusters.sh
./99-2-teardown-kops-gce.sh
#./csm-alpha-cleanup.sh

remove_sa(){
    local sa="${1-}"; shift
    local role_bindings=$(set -x; gcloud projects get-iam-policy ${PROJECT} --flatten "bindings[].members" --filter "bindings.members:${sa}" --format 'value(bindings.role)')
    for rb in ${role_bindings}; do
      (set -x; gcloud projects remove-iam-policy-binding ${PROJECT} --member "serviceAccount:${sa}" --role "${rb}" --quiet --no-user-output-enabled)
    done
    (set -x; gcloud iam service-accounts delete ${sa} --quiet --no-user-output-enabled)
}

#remove_sa csm-sync-agent@$PROJECT.iam.gserviceaccount.com
#remove_sa stackdriver-adapter@$PROJECT.iam.gserviceaccount.com


rm -rf ./tmp

