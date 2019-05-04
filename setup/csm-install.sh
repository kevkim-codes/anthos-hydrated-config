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




set -o errexit
set -o nounset
set -o pipefail




source ./resources/csm-functions.sh



echo "Creating a GKE cluster..."
gcloud beta container clusters create ${CLUSTER} \
    --project=${PROJECT_ID} \
    --zone=${ZONE} \
    --cluster-version=${CLUSTER_VERSION} \
    --machine-type=n1-standard-2 \
    --num-nodes=4 \
    --enable-stackdriver-kubernetes 
 



##########################



check_account_role

ENABLE_MANAGED_CA="N"
ENABLE_IAP="N"
INSTALL_APP="N"

check_install_tools
enable_gcp_apis
create_alpha_svc_acct
create_sync_agent_svc_acct
create_mesh

# Single CLuster Vars
#ZONE=us-central1-b
#CLUSTER=central

echo "------ Processing Clusters ------"
FILES=./clusters/*.yaml
for f in $FILES
do
    CLUSTER=$(yq.v2 r $f  metadata.name)
    ZONE=$(yq.v2 r $f  spec.location.zone)

    kubectx $CLUSTER

    create_gke_cluster


    echo $CLUSTER $ZONE
    install_stackdriver_adapter
    install_csm_sync_agent
    create_sync_agent_secret
    verify_sync_agent
    install_csm_insights
    verify_csm_insights
 
done

echo "------ END Processing Clusters ------"

cleanup



