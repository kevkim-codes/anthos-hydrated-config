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
echo "### Prepare remote cluster for Hub"
echo "### "

## Store Remote Kubeconfig
REMOTE_KUBECONFIG=$WORK_DIR/kops-$REMOTE_CLUSTER_NAME-kubeconfig.yaml
kubectx $REMOTE_CLUSTER_NAME_BASE
kubectl config view --minify --flatten > $REMOTE_KUBECONFIG

## Create GKE Connect Service Account
export GKE_CONNECT_SA=gke-connect-sa
export GKE_SA_CREDS=$WORK_DIR/gke-connect-sa-creds.json
gcloud iam service-accounts create $GKE_CONNECT_SA --project=$PROJECT_ID

## Assign it GKE Connect rights
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$GKE_CONNECT_SA@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/gkehub.connect"

## Create and download a key
gcloud iam service-accounts keys create $GKE_SA_CREDS --project=$PROJECT_ID \
  --iam-account=$GKE_CONNECT_SA@$PROJECT_ID.iam.gserviceaccount.com 

## Create k8s service account and cluster-admin clusterrolebinding 
export KSA=remote-admin-sa
kubectx $REMOTE_CLUSTER_NAME_BASE
kubectl create serviceaccount $KSA
kubectl create clusterrolebinding ksa-admin-binding \
--clusterrole cluster-admin --serviceaccount default:$KSA