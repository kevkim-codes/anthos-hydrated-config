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



export KOPS_CLUSTER_NAME=$KOPS_CLUSTER_NAME_BASE.k8s.local

#export KOPS_CLUSTER_NAME=remote-12142.k8s.local
#export GKE_CONNECT_SA=gke-connect-sa
#export GKE_SA_CREDS=creds.json
#export KOPS_STORE=gs://csp-demo-31354-6656

gcloud alpha container hub unregister-cluster --context=$KOPS_CLUSTER_NAME

kops delete cluster --name $KOPS_CLUSTER_NAME --state $KOPS_STORE --yes

#gcloud projects remove-iam-policy-binding \
#    $PROJECT_ID \
#    --member="serviceAccount:$GKE_CONNECT_SA@$PROJECT_ID.iam.gserviceaccount.com" \
#    --role="roles/gkehub.connect"

#gcloud iam service-accounts delete \
#    $GKE_CONNECT_SA@$PROJECT_ID.iam.gserviceaccount.com \
#    --project=$PROJECT_ID \
#    --quiet

#rm $GKE_SA_CREDS
#rm kops-kubeconfig.yaml
kubectx -d $KOPS_CLUSTER_NAME 

gsutil rb $KOPS_STORE
