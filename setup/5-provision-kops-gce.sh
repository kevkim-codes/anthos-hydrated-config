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
echo "### Begin provision remote cluster"
echo "### "

# Enable the right APIs
gcloud services enable \
        --project=$PROJECT_ID \
        container.googleapis.com \
        gkehub.googleapis.com \
        gkeconnect.googleapis.com

# Unlock GCE features (?)
export KOPS_FEATURE_FLAGS=AlphaAllowGCE

gsutil mb $KOPS_STORE

# Make sure bucket is created before cluster creation
n=0
until [ $n -ge 5 ]
do
    gsutil ls | grep $KOPS_STORE && break 
    n=$[$n+1]
    sleep 3
done


kops create cluster --name=$REMOTE_CLUSTER_NAME --zones=us-central1-a --state=$KOPS_STORE --project=${PROJECT} --yes

for (( c=1; c<=30; c++))
do
	echo "Check if cluster is ready $c"
        CHECK=`kops validate cluster --name $REMOTE_CLUSTER_NAME --state $KOPS_STORE | grep ready | wc -l`
        if [[ "$CHECK" == "1" ]]; then
                break;
        fi
        sleep 10
done

sleep 20


kubectl create clusterrolebinding user-cluster-admin --clusterrole cluster-admin --user $(gcloud config get-value account)



kubectx $REMOTE_CLUSTER_NAME_BASE=$REMOTE_CLUSTER_NAME && kubectx $REMOTE_CLUSTER_NAME_BASE
######################
# Add Policy Manager #
######################

kubectl apply -f https://storage.googleapis.com/nomos-release/operator-rc/nomos-operator-v0.1.15-rc.1/nomos-operator.yaml;
#(set -x; cat ./resources/policy_repo.yaml | sed 's@<REPO_URL>@'${REPO_URL}@g | sed 's@<CLUSTER_NAME>@'${KOPS_CLUSTER_NAME}@g | kubectl apply -f -)




###############
# GKE Connect #
#             #
# Use as Demo #
###############

# Performs the: Configure, Connect & Register steps from above
# Creates the manifest file and deploys it to the remote cluster
#gcloud alpha container hub register-cluster $KOPS_CLUSTER_NAME\
# --context=$KOPS_CLUSTER_NAME \
# --service-account-key-file=$GKE_SA_CREDS \
# --kubeconfig-file=$KONFIG_FILE \
# --docker-image=gcr.io/gkeconnect/gkeconnect-gce:gkeconnect_20190311_00_00 \
# --project=$PROJECT_ID
 ## Tries to use gcr.io/gkeconnect/gkeconnect-gce:latest by default which errors out
 ##                                                  so we set it manually
 ## Going through the UI would use an older version:
 ##             gcr.io/gkeconnect/gkeconnect-gce:gkeconnect_20190217_01_00

#printf "\n"
#printf "Use the token to login to $KOPS_CLUSTER_NAME in console.cloud.google.com/kubernetes"

#echo ""
#echo "KOPS env variables:"
#echo "export KOPS_CLUSTER_NAME=$KOPS_CLUSTER_NAME"
#echo "export KOPS_STORE=$KOPS_STORE"
#echo "export GKE_CONNECT_SA=$GKE_CONNECT_SA"
#echo "export GKE_SA_CREDS=$GKE_SA_CREDS"