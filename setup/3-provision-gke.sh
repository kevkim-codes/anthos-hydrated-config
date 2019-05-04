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
echo "### Begin Provision GKE"
echo "### "


CLUSTER_VERSION="1.12.6-gke.10"

#PROJECT_ID="${PROJECT_ID:?PROJECT_ID env variable must be specified}"
#PROJECT=$PROJECT_ID

#go get gopkg.in/mikefarah/yq.v2
FILES=./clusters/*.yaml
for f in $FILES
do
    NAME=$(yq.v2 r $f  metadata.name)
    ZONE=$(yq.v2 r $f  spec.location.zone)
    echo $NAME $ZONE

    gcloud beta container clusters create $NAME --zone $ZONE \
        --username "admin" \
        --machine-type "n1-standard-2" \
        --image-type "COS" \
        --disk-size "100" \
        --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
        --num-nodes "4" \
        --network "default" \
        --enable-cloud-logging \
        --enable-cloud-monitoring \
        --enable-ip-alias \
        --cluster-version=${CLUSTER_VERSION} \
        --enable-stackdriver-kubernetes

    gcloud container clusters get-credentials ${NAME} --zone ${ZONE}

    kubectx ${NAME}=gke_${PROJECT}_${ZONE}_${NAME}
    kubectx ${NAME}
    
    kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user="$(gcloud config get-value core/account)"

    

done


kubectx ${CONTROL_CLUSTER}

kubectl apply -f ./resources/cluster-registry-crd.yaml
kubectl apply -f ./clusters
