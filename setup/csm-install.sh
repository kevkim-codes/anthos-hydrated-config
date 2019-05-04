



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



