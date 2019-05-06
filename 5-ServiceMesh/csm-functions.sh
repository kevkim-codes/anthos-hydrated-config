#!/bin/bash

# This script is provided to the users of CSM Alpha to facilitate their
# onboarding experience. The script creates a mesh, adds a GKE cluster
# that is enrolled in the mesh and optionally deploy an nginx app to the
# cluster.
#
# Usage:
# ./csm-alpha-onboard.sh
#
# Please note the script has ONLY be tested against the GCP Cloud Shell.
#

set -o errexit
set -o nounset
set -o pipefail

# Clean up service account and restore gcloud to use the user's account
cleanup() {
  echo "Cleaning up temporary service account and restoring gcloud account..."
  restore_gcloud_account
  # remove iam policy bindings before removing the service accounts
  for sa in ${temp_svc_acct}; do
    local role_bindings=$(set -x; gcloud projects get-iam-policy ${PROJECT_ID} --flatten "bindings[].members" --filter "bindings.members:${sa}" --format 'value(bindings.role)')
    for rb in ${role_bindings}; do
      (set -x; gcloud projects remove-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${sa}" --role "${rb}" --quiet --no-user-output-enabled)
    done
    (set -x; gcloud iam service-accounts delete ${sa} --quiet --no-user-output-enabled)
  done
  # remove service account secrets from local
  for sp in ${temp_secret_path}; do
    rm -f ${sp}
  done
}

# check if the current account has project editor/owner role
check_account_role() {
  echo "Checking if you (${ACCOUNT}) have Project Editor/Owner role on this project (${PROJECT_ID})."
  if (set -x; gcloud projects get-iam-policy ${PROJECT_ID} --no-user-output-enabled); then
    local acct_roles=$(set -x; gcloud projects get-iam-policy ${PROJECT_ID} --flatten "bindings[].members" --filter "bindings.members:${ACCOUNT}" --format 'value(bindings.role)')
    for ar in ${acct_roles}; do
      if [[ ${ar} =~ ^("roles/owner"|"roles/editor")$ ]]; then
        return 0
      fi
    done;
    echo "You (${ACCOUNT}) don't have Project Editor/Owner role on this project (${PROJECT_ID}). Please check the IAM page again or switch account."
    exit 1
  else
    echo "You (${ACCOUNT}) don't have Project Editor/Owner role on this project (${PROJECT_ID}). Please check the IAM page again or switch account."
    exit 1
  fi
}

# run cleanup() upon script error and non zero return code
trap 'if [ $? -ne 0 ]; then cleanup; fi' EXIT

C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[1;36m'
C_RED='\033[0;31m'
NO_COLOR='\033[0m'

# Linux cs-6000-devshell is a safe string to check for cloud shell environment
#if [[ ! $(uname -a) =~ ^"Linux cs-6000-devshell" ]]; then
#  echo -e "${C_RED}Currently the script can only be run in Google Cloud Shell. Please open a cloud shell in your project and try again. If you have additional questions, please contact us at csm-users@googlegroups.com${NO_COLOR}"
#  exit 0
#fi

#echo "All executed gcloud, kubectl and gsutil commands are printed out."
#echo "Getting some initial values for the script..."

ACCOUNT=$(set -x; gcloud config get-value account 2> /dev/null)
PROJECT_ID=$(set -x; gcloud config get-value project 2> /dev/null)
PROJECT_NUMBER=$(set -x; gcloud projects describe --format='value(projectNumber)' ${PROJECT_ID})
MESH="${PROJECT_ID}-mesh"

# zone list is static to avoid additional prompt and wait time to get the zones from GCE API if not enabled
ZONE_LIST="us-east1-b us-east1-c us-east1-d us-east4-c us-east4-b us-east4-a us-central1-c us-central1-a\
 us-central1-f us-central1-b us-west1-b us-west1-c us-west1-a europe-west4-a europe-west4-b europe-west4-c\
 europe-west1-b europe-west1-d europe-west1-c europe-west3-c europe-west3-a europe-west3-b europe-west2-c\
 europe-west2-b europe-west2-a asia-east1-b asia-east1-a asia-east1-c asia-southeast1-b asia-southeast1-a\
 asia-southeast1-c asia-northeast1-b asia-northeast1-c asia-northeast1-a asia-south1-c asia-south1-b\
 asia-south1-a australia-southeast1-b australia-southeast1-c australia-southeast1-a southamerica-east1-b\
 southamerica-east1-c southamerica-east1-a asia-east2-a asia-east2-b asia-east2-c europe-north1-a\
 europe-north1-b europe-north1-c northamerica-northeast1-a northamerica-northeast1-b northamerica-northeast1-c\
 us-west2-a us-west2-b us-west2-c"
LOG_PATH="${HOME}/csm-alpha-onboard-logs"
MESH_NAME=""
SAMPLE_APP_URL=""
ISTIO_VERSION="1.1.3"
ISTIO_PATH=""
CLUSTER_VERSION="1.12.6-gke.10"
FED_SVC_ACCT=""

exec &> >(tee "${LOG_PATH}")

# temp service accounts and secrets to clean up
temp_svc_acct=""
temp_secret_path=""

# global alpha service account values
alpha_svc_acct=""
alpha_svc_acct_secret_path=""

# check and install the necessary tools needed in the script
check_install_tools() {
  echo "Checking if curl is installed..."
  if ! [[ -x "$(command -v curl)" ]]; then
    echo "Installing curl..."
    sudo apt-get install curl
  fi
  echo "Checking if oauth2l is installed..."
  if ! [[ -x "$(command -v oauth2l)" ]]; then
    echo "Installing oauth2l..."
    go get github.com/google/oauth2l
    go install github.com/google/oauth2l
  fi
  echo "Checking if jq is installed..."
  if ! [[ -x "$(command -v jq)" ]]; then
    echo "Installing jq..."
    sudo apt-get install jq
  fi
}

# restore gcloud to use the user's account
restore_gcloud_account() {
  echo "Restoring gcloud back to use your account"
  (set -x; gcloud config set account ${ACCOUNT} --no-user-output-enabled)
}

# create a shared alpha service account used to access alpha features
create_alpha_svc_acct() {
  echo "Creating a service account alpha-svc-acct for Alpha features..."
  alpha_svc_acct=$(create_service_account alpha-svc-acct)
  temp_svc_acct="${temp_svc_acct} ${alpha_svc_acct}"
  shopt -s nocasematch
  if [[ ${ENABLE_MANAGED_CA} == y ]]; then
    grant_service_account_roles ${alpha_svc_acct} "roles/container.admin" "roles/iam.serviceAccountActor" "roles/iam.serviceAccountIdentityBindingAdmin" "roles/meshmanagement.meshOperator"
  else
    grant_service_account_roles ${alpha_svc_acct} "roles/meshmanagement.meshOperator"
  fi
  alpha_svc_acct_secret_path=$(create_service_account_private_key ${alpha_svc_acct})
  temp_secret_path="${temp_secret_path} ${alpha_svc_acct_secret_path}"
}

# set up gcloud to access gke alpha api
setup_gcloud_gke_alpha_api() {
  echo "Setting up gcloud to use the GKE v1alpha1 API..."
  (set -x; gcloud auth activate-service-account ${alpha_svc_acct} --key-file ${alpha_svc_acct_secret_path})
  echo "gcloud can now access GKE v1alpha1 API."
}

# enable required GCP APIs
enable_gcp_apis() {
  echo "Enabling the GCP CloudResourceManager API..."
  if (set -x; gcloud services enable cloudresourcemanager.googleapis.com --project ${PROJECT_ID}); then
    echo "The GCP Cloud Resource Manager API is enabled."
  else
    echo "The GCP Cloud Resource Manager API cannot be enabled. Please check your permissions."
    echo "Aborting!"
    exit 1
  fi
  echo "Enabling the GCP MeshManagement API..."
  if (set -x; gcloud services enable meshmanagement.googleapis.com --project ${PROJECT_ID}); then
    echo "The GCP MeshManagement API is enabled."
  else
    echo "The GCP MeshManagement API cannot be enabled. Please contact csm-users@googlegroups.com."
    echo "Aborting!"
    exit 1
  fi
  echo "Enabling the GCP GKE API..."
  if (set -x; gcloud services enable container.googleapis.com --project ${PROJECT_ID}); then
    echo "The GCP GKE API is enabled."
  else
    echo "The GCP GKE API cannot be enabled. Please check your permissions."
    echo "Aborting!"
    exit 1
  fi
  echo "Enabling the GCP IAM API..."
  if (set -x; gcloud services enable iam.googleapis.com --project ${PROJECT_ID}); then
    echo "The GCP IAM API is enabled."
  else
    echo "The GCP IAM API cannot be enabled. Please check your permissions."
    echo "Aborting!"
    exit 1
  fi
  echo "Enabling the GCP Context Graph API..."
  if (set -x; gcloud services enable contextgraph.googleapis.com --project ${PROJECT_ID}); then
    echo "The GCP Context Graph API is enabled."
  else
    echo "The GCP Context Graph API cannot be enabled. Please check your permissions."
    echo "Aborting!"
    exit 1
  fi
  shopt -s nocasematch
  if [[ ${ENABLE_MANAGED_CA} == y ]]; then
    echo "Enabling the GCP Managed CA API..."
    if (set -x; gcloud services enable istioca.googleapis.com --project ${PROJECT_ID}); then
      echo "The GCP Managed CA API is enabled."
    else
      echo "The GCP Managed CA API cannot be enabled. Please check your permissions."
      echo "Aborting!"
      exit 1
    fi
  fi
}

# Creates a service account with the specified name
create_service_account() {
  local sa="${1-}"; shift
  # Using head to limit a single result because gcloud limit is currently not applied as the last flag
  local old_svc_acct=$((set -x; gcloud iam service-accounts list --filter "email ~ ^"${sa}'@'" " --format 'value(email)') | head -n 1)
  if [[ -z ${old_svc_acct} ]]; then
    if (set -x; gcloud iam service-accounts create ${sa} --display-name ${sa} --project ${PROJECT_ID} --no-user-output-enabled); then
      # Service Account list is eventual consistent, so doing retries here if the service account does not come up right after creation
      local interval=1
      # 30 secs is a safe timeout
      local timeout=30
      local curr_time=0
      local csm_svc_acct=$((set -x; gcloud iam service-accounts list --filter "email ~ ^"${sa}'@'" " --format 'value(email)') | head -n 1)
      until [[ -n ${csm_svc_acct} ]] || [ ${curr_time} -eq ${timeout} ]; do
       sleep ${interval}
       csm_svc_acct=$(gcloud iam service-accounts list --filter "email ~ ^"${sa}'@'" " --format 'value(email)' | head -n 1)
       ((curr_time+=interval))
      done
      echo ${csm_svc_acct}
    else
      echo "Cannot create the service account. Please see the errors above."
      exit 1
    fi
  else
    echo ${old_svc_acct}
  fi
}

# Grants a service account with roles listed in the arguments
grant_service_account_roles() {
  local sa="${1-}"; shift
  echo "Granting roles to ${sa} ..."
  if [[ ! ${sa} =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$ ]]; then
    echo -e "${C_RED}An invalid service account is being used to grant roles. Please check if the service account name is correct or contact csm-users@googlegroups.com. ${NO_COLOR}"
    exit 1
  fi
  for role in "$@"; do
    echo "Granting role ${role} to service account ${sa} ..."
    (set -x; gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${sa}" --role ${role} --no-user-output-enabled)
  done
}

# Creates a private key for the specified service account
create_service_account_private_key() {
  local sa="${1-}"; shift
  local svc_acct_name=$(echo ${sa} | cut -d@ -f1)
  local secret_path="${HOME}/${svc_acct_name}_key.json"
  (set -x; gcloud iam service-accounts keys create ${secret_path} --iam-account ${sa})
  echo ${secret_path}
}

# create mesh process deals with situations when there is no mesh, mesh is
# created and mesh is pending deletion.
create_mesh() {
  local old_mesh=$((set -x; curl -H "$(oauth2l header --json "${alpha_svc_acct_secret_path}" cloud-platform)" -X GET "https://meshmanagement.googleapis.com/v1alpha2/projects/${PROJECT_NUMBER}/meshes/${PROJECT_NUMBER}" --silent) | jq -r ".name?")
  local old_mesh_state=$((set -x; curl -H "$(oauth2l header --json "${alpha_svc_acct_secret_path}" cloud-platform)" -X GET "https://meshmanagement.googleapis.com/v1alpha2/projects/${PROJECT_NUMBER}/meshes/${PROJECT_NUMBER}" --silent) | jq -r ".lifecycleState?")
  if [[ ${old_mesh} == 'null' ]]; then
    echo "Creating the mesh ${MESH}..."
    if (set -x; curl -H "$(oauth2l header --json "${alpha_svc_acct_secret_path}" cloud-platform)" -X POST "https://meshmanagement.googleapis.com/v1alpha2/projects/${PROJECT_NUMBER}/meshes/?mesh.display_name=${MESH}" --silent); then
      echo -e "${C_GREEN}Mesh ${MESH} created.${NO_COLOR}"
    else
      echo -e "${C_RED}Cannot create mesh. Please see the errors and contact csm-users@googlegroups.com.${NO_COLOR}"
      exit 1
    fi
  else
    if [[ ${old_mesh_state} == "DELETE_REQUESTED" ]]; then
      echo -e "${C_RED}Mesh ${old_mesh} was requested to be deleted. Please wait until the mesh is deleted before creating a new mesh on this project.${NO_COLOR}"
      exit 1
    else
      echo -e "${C_GREEN}Mesh ${old_mesh} was already created.${NO_COLOR}"
      MESH=${old_mesh}
    fi
  fi
  MESH_NAME=$((set -x; curl -H "$(oauth2l header --json "${alpha_svc_acct_secret_path}" cloud-platform)" -X GET "https://meshmanagement.googleapis.com/v1alpha2/projects/${PROJECT_NUMBER}/meshes/${PROJECT_NUMBER}" --silent) | jq -r ".name?")
  if [[ ! ${MESH_NAME} =~ ^projects/[0-9]+/meshes/[0-9]+? ]]; then
    echo -e "${C_RED}Mesh name ${MESH_NAME} is invalid. Please rerun the script and try again.${NO_COLOR}"
    exit 1
  fi
}

install_helm() {
  echo "Installing helm..."
  curl -s "https://raw.githubusercontent.com/helm/helm/master/scripts/get" | bash -s -- -v v2.13.0
}

create_fsa() {
  echo "Creating a Federating Service Account..."
  FED_SVC_ACCT=$(create_service_account csm-fsa)
}

create_mpi_gke_cluster() {
  if [[ -z ${FED_SVC_ACCT} ]]; then
    echo -e "${C_RED}The csm-fsa service account is not created. Please rerun the script and try again.${NO_COLOR}"
    exit 1
  fi
  echo "Creating a GKE cluster with Managed Pod Identity..."
  (set -x; gcloud alpha container clusters create ${CLUSTER} --project=${PROJECT_ID} --zone=${ZONE} --cluster-version=${CLUSTER_VERSION} --machine-type=n1-standard-2 --num-nodes=4 \
  --enable-kubernetes-alpha --enable-managed-pod-identity --enable-stackdriver-kubernetes --no-enable-autorepair --no-enable-autoupgrade --federating-service-account=${FED_SVC_ACCT} --quiet)
  echo "Configuring the IAM to map the GKE cluster to the Federating Service Account..."
  local cluster_api_url="https://container.googleapis.com/v1/projects/${PROJECT_ID}/locations/${ZONE}/clusters/${CLUSTER}"
  # check if there is existing binding and get its name
  local existing_identity_binding_name=$((set -x; gcloud alpha iam service-accounts identity-bindings list --service-account=${FED_SVC_ACCT} --format json) | jq -r --arg cluster_api_url "${cluster_api_url}" '.identityBinding[] | select(.oidc.url==$cluster_api_url) | .name')
  # if an existing binding exists, skip creation
  if [[ -n ${existing_identity_binding_name} ]]; then
    echo "GKE cluster to the Federating Service Account mapping exists, skipping creating the identity binding..."
  else
    local attribute_translator="google.sub=inclaim['kubernetes.io']['namespace']+ ':' +inclaim['kubernetes.io']['serviceaccount']['name'],cluster=inclaim['iss']"
    if ! (set -x; gcloud alpha iam service-accounts identity-bindings create --service-account=${FED_SVC_ACCT} --acceptance-filter=true --attribute-translator-cel="${attribute_translator}" --oidc-issuer-url="${cluster_api_url}" --oidc-max-token-lifetime=172800); then
      echo -e "${C_RED}There is an issue mapping the GKE cluster to the Federating Service Account, please contact us at csm-users@googlegroups.com.${NO_COLOR}"
      exit 1
    fi
  fi
  restore_gcloud_account
  echo "Getting credentials for kubectl to use..."
  (set -x; gcloud container clusters get-credentials ${CLUSTER} --zone ${ZONE})
  echo "Granting cluster admin RBAC permissions to you on the cluster..."
  (set -x; kubectl create clusterrolebinding cluster-admin-binding --clusterrole="cluster-admin" --user=${ACCOUNT})
}

create_gke_cluster() {
  if [ ${cluster_exists} = "N" ]; then
    echo "Creating a GKE cluster..."
    (set -x; gcloud beta container clusters create ${CLUSTER} --project=${PROJECT_ID} --zone=${ZONE} --cluster-version=${CLUSTER_VERSION} --machine-type=n1-standard-2 --num-nodes=4 --enable-stackdriver-kubernetes --quiet)
  fi
  echo "Getting credentials for kubectl to use..."
  (set -x; gcloud container clusters get-credentials ${CLUSTER} --zone ${ZONE})
 # echo "Granting cluster admin RBAC permissions to you on the cluster..."
 # (set -x; kubectl create clusterrolebinding cluster-admin-binding --clusterrole="cluster-admin" --user=${ACCOUNT})
}

download_istio() {
  local osext="linux"
  local name="istio-${ISTIO_VERSION}"
  local url="https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-${osext}.tar.gz"
  echo "Downloading ${name} from ${url} ..."
  curl -s -L "${url}" | tar xz -C ${HOME}
  ISTIO_PATH="${HOME}/${name}"
  echo "Downloaded into ${ISTIO_PATH}:"
}

install_istio_control_plane() {
  echo "Installing Istio on your cluster..."
  (set -x; kubectl apply -f "${ISTIO_PATH}/install/kubernetes/helm/istio-init/files")
  shopt -s nocasematch
  local BASE_HELM="helm template ${ISTIO_PATH}/install/kubernetes/helm/istio --name istio --namespace istio-system --set mixer.telemetry.autoscaleEnabled=false,pilot.env.PILOT_ENABLE_FALLTHROUGH_ROUTE=1,sidecarInjectorWebhook.rewriteAppHTTPProbe=true"
  mtls_enabled=true
  if [[ ${ENABLE_MANAGED_CA} == y ]]; then
    sed -i 's/trustDomain: ""/trustDomain: "'${FED_SVC_ACCT}'"/' "${ISTIO_PATH}/install/kubernetes/helm/istio/example-values/values-istio-googleca.yaml"
    if [[ ${ENABLE_IAP} == n ]]; then
      (set -x; ${BASE_HELM} --values "${ISTIO_PATH}/install/kubernetes/helm/istio/example-values/values-istio-googleca.yaml" > "${HOME}/istio.yaml")
    else
      (set -x; ${BASE_HELM} --set "gateways.istio-ingressgateway.type=NodePort" --values "${ISTIO_PATH}/install/kubernetes/helm/istio/example-values/values-istio-googleca.yaml" > "${HOME}/istio.yaml")
    fi
  else
    if [[ ${ENABLE_IAP} == n ]]; then
      mtls_enabled=false
      (set -x; ${BASE_HELM} --set "global.mtls.enabled=false" > "${HOME}/istio.yaml")
    else
      (set -x; ${BASE_HELM} --set "global.mtls.enabled=true,gateways.istio-ingressgateway.type=NodePort" > "${HOME}/istio.yaml")
    fi
  fi
  (set -x; kubectl create namespace istio-system)
  (set -x; kubectl apply -f "${HOME}/istio.yaml")
}

install_stackdriver_adapter() {
  echo "Installing the Stackdriver Adapter..."
  echo "Creating a service account for the Stackdriver Adapter..."
  local svc_acct=$(create_service_account stackdriver-adapter)
  grant_service_account_roles ${svc_acct} "roles/contextgraph.asserter" "roles/logging.logWriter" "roles/monitoring.metricWriter"
  local secret_path=$(create_service_account_private_key ${svc_acct})
  echo "Generating the secret for the Stackdriver Adapter to use..."
  (set -x; kubectl create secret -n istio-system generic telemetry-adapter-secret --from-file=service-account.json="${secret_path}")
  echo "Removing the secret file from local..."
  rm ${secret_path}
  (set -x; gsutil cat gs://csm-alpha-artifacts/stackdriver/stackdriver.yaml | sed '/pushInterval: 10s/a\  serviceAccountPath: "/var/run/secrets/istio.io/telemetry/adapter/service-account.json"' | sed 's@<mesh_uid>@'${MESH_NAME}@g | kubectl apply -f -)
}

install_csm_sync_agent() {
  local cluster_identity="projects/${PROJECT_NUMBER}/locations/${ZONE}/clusters/${CLUSTER}"
  local mesh_cluster=$((set -x; curl -H "$(oauth2l header --json "${alpha_svc_acct_secret_path}" cloud-platform)" -X GET "https://meshmanagement.googleapis.com/v1alpha2/projects/${PROJECT_NUMBER}/meshes/${PROJECT_NUMBER}" --silent) | jq -r ".cluster?")
  if [[ ${mesh_cluster} != "null" ]]; then
    echo -e "${C_YELLOW}A cluster ${mesh_cluster} was already enrolled in the Mesh. CSM Alpha only supports a single cluster for a mesh currently. Please consider deleting the cluster ${mesh_cluster}.${NO_COLOR}"
  fi
  local update_mesh_body=$((set -x; curl -H "$(oauth2l header --json "${alpha_svc_acct_secret_path}" cloud-platform)" -X GET "https://meshmanagement.googleapis.com/v1alpha2/projects/${PROJECT_NUMBER}/meshes/${PROJECT_NUMBER}" --silent) | jq -r '. + {cluster : $value}'  --arg value "${cluster_identity}")
  echo "Updating the mesh to use cluster ${cluster_identity}..."
  # if updating the mesh fails, exit the script as sync agent will fail for sure
  if ! (set -x; curl -H "$(oauth2l header --json "${alpha_svc_acct_secret_path}" cloud-platform)" -H "Content-Type: application/json" -X PATCH "https://meshmanagement.googleapis.com/v1alpha2/projects/${PROJECT_NUMBER}/meshes/${PROJECT_NUMBER}" -d "${update_mesh_body}" --silent); then
    echo -e "${C_RED}Updating the Mesh with the following body message failed. Please see the error message above and/or contact us at csm-users@googlegroups.com${NO_COLOR}"
    echo ${update_mesh_body}
    exit 1
  fi
  echo "Installing CSM Sync Agent..."
  (set -x; gsutil cat gs://csm-alpha-artifacts/sync-agent/k8s/csm-sync-agent-alpha.yaml | sed 's@<mesh-name>@'${MESH_NAME}@g | sed 's@<cluster>@'${cluster_identity}@g | kubectl apply -f -)
}

create_sync_agent_svc_acct() {
  echo "Creating a service account for the CSM Sync Agent..."
  create_service_account csm-sync-agent
}

# create the k8s secret used by the sync agent
create_sync_agent_secret() {
  echo "Creating a service account for the CSM Sync Agent..."
  local svc_acct=$(create_service_account csm-sync-agent)
  grant_service_account_roles ${svc_acct} "roles/meshmanagement.meshOperator" "roles/meshmanagement.namespaceAdmin"
  local secret_path=$(create_service_account_private_key ${svc_acct})
  echo "Generating the secret for the CSM Sync Agent to use..."
  (set -x; kubectl create secret -n csm generic csm-sync-agent-gcp-creds --from-file=service-account.json="${secret_path}")
  echo "Removing the secret file from local..."
  rm ${secret_path}
}

# verify if the sync agent is in RUNNING state; 1 min wait is a safe time period
# the sync agent picks up the secret
verify_sync_agent() {
  echo "Checking the CSM Sync Agent every second for RUNNING state..."
  local interval=1
  local timeout=60
  local curr_time=0
  local pod_status=$(set -x; kubectl get pods -n csm -l app=csm-sync-agent -o jsonpath='{.items[*].status.phase}')
  until [ ${pod_status} == "Running" ] || [ ${curr_time} -eq ${timeout} ]; do
   sleep ${interval}
   pod_status=$(kubectl get pods -n csm -l app=csm-sync-agent -o jsonpath='{.items[*].status.phase}')
   ((curr_time+=interval))
  done
  if [ ${pod_status} == "Running" ]; then
    echo -e "${C_GREEN}The CSM Sync Agent is running.${NO_COLOR}"
  else
    echo -e "${C_RED}The CSM Sync Agent is not running after the timeout of one minute, please check the CSM Sync Agent events or contact us at csm-users@googlegroups.com${NO_COLOR}"
  fi
}

install_csm_insights() {
  echo "Installing Security Insights..."
  gcloud services enable meshsecurityinsights.googleapis.com
  # fetch template yaml, set mesh name and apply yaml
  (set -x; gsutil cat gs://managed-istio-security-alpha-files/security_analytics/template.yaml | sed "s?__MESH_ID__?${MESH_NAME}?g" | kubectl apply -f -)
  hasMeshProvider=$(kubectl get pods --namespace csm -l app=csm-insights-meshstate)
  if [[ -z "$hasMeshProvider" ]]; then
    echo "Security Insights Mesh State Provider does not exist"
  else
    echo "Security Insights Mesh State Provider created successfully"
  fi

  hasAdapter=$(kubectl get pods --namespace csm -l app=csm-insights-adapter)
  if [[ -z "$hasAdapter" ]]; then
    echo "Security Insights Adapter does not exist"
  else
    echo "Security Insights Adapter created successfully"
  fi
}

verify_csm_insights() {
  echo "Checking Security Insights installation"
  # verify pods exist and are in running state
  local check_counter=0
  while [[ $check_counter -le 5 ]]
  do
    sleep 5
    meshstateRunning=$(kubectl get pods -n csm -l app=csm-insights-meshstate -o jsonpath='{.items[*].status.phase}')
    adapterRunning=$(kubectl get pods -n csm -l app=csm-insights-adapter -o jsonpath='{.items[*].status.phase}')
    if [[ ${meshstateRunning} != "Running" || ${adapterRunning} != "Running" ]]; then
      ((check_counter+=1))
      continue
    else
      echo "Security Insights running successfully"
      return 0
    fi
  done
  echo "Security Insights not running. Please contact csm-users@googlegroups.com"
}

iap_create_firewall_rules() {
  echo "Creating firewall rules for IAP..."
  local ingress_port=$(set -x; kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
  local secure_ingress_port=$(set -x; kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
  local hc_ingress_port=$(set -x; kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="status-port")].nodePort}')
  if [[ -z $(set -x; gcloud compute firewall-rules list --filter "name:allow-gateway-http" --format 'value(name)') ]]; then
    (set -x; gcloud compute firewall-rules create allow-gateway-http --allow tcp:${ingress_port})
  fi
  if [[ -z $(set -x; gcloud compute firewall-rules list --filter "name:allow-gateway-https" --format 'value(name)') ]]; then
    (set -x; gcloud compute firewall-rules create allow-gateway-https --allow tcp:${secure_ingress_port})
  fi
  if [[ -z $(set -x; gcloud compute firewall-rules list --filter "name:allow-gateway-status-port" --format 'value(name)') ]]; then
    (set -x; gcloud compute firewall-rules create allow-gateway-status-port --allow tcp:${hc_ingress_port})
  fi
}

deploy_test_bookinfo_app() {
  echo "Installing the bookinfo app to your cluster ${CLUSTER} ..."
  (set -x; kubectl apply -f <(${ISTIO_PATH}/bin/istioctl kube-inject -f ${ISTIO_PATH}/samples/bookinfo/platform/kube/bookinfo.yaml))
  (set -x; kubectl apply -f "${ISTIO_PATH}/samples/bookinfo/networking/bookinfo-gateway.yaml")
  (set -x; kubectl apply -f <(${ISTIO_PATH}/bin/istioctl kube-inject -f ${ISTIO_PATH}/samples/bookinfo/platform/kube/bookinfo-add-serviceaccount.yaml) --validate=false)
  # Sets details service in bookinfo app to be mtls disabled, so we can observe insights recommendation for mtls migration.
  (set -x; cat <<EOF | kubectl apply -f -
apiVersion: authentication.istio.io/v1alpha1
kind: Policy
metadata:
  name: details
  namespace: default
spec:
  targets:
  - name: details
  peers:
  - mtls:
      mode: PERMISSIVE
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: details-destrule
  namespace: default
spec:
  host: details.default.svc.cluster.local
  trafficPolicy:
    tls:
      mode: DISABLE
EOF
  )
  if [[ ${ENABLE_IAP} == n ]]; then
    echo "Checking the Istio ingressgateway every second for its readiness..."
    local interval=1
    local timeout=90
    local curr_time=0
    local ingress_host=$(set -x; kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    until [[ ${ingress_host} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || [ ${curr_time} -eq ${timeout} ]; do
      sleep ${interval}
      ingress_host=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
      ((curr_time+=interval))
    done
    if [[ ${ingress_host} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
      local ingress_port=$(set -x; kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
      SAMPLE_APP_URL="http://${ingress_host}:${ingress_port}/productpage"
    else
      echo -e "${C_RED}The Istio ingressgateway is not running after the timeout of 90 seconds, please check the status of the ingressgateway or contact us at csm-users@googlegroups.com${NO_COLOR}"
    fi
  fi
}

check_zone() {
  local zone_to_check="${1-}"; shift
  for z in ${ZONE_LIST}; do
    if [[ ${z} == ${zone_to_check} ]]; then
      return 0
    fi
  done
  return 1
}

check_account_role

#echo "Welcome to CSM Alpha"
#echo "At the end of the script, you will have a new Mesh ${MESH} and a new zonal GKE cluster with Istio ${ISTIO_VERSION} and CSM installed that syncs its data to the Mesh."
#echo "In addition, the cluster is enabled with workload identity provisioning with the Managed Certificate Authority managing and issuing keys and certs for your workloads."
#echo "The cluster created is in alpha state and will be deleted after 30 days."
#echo -e "${C_YELLOW}CSM Alpha only supports a single cluster for a mesh.${NO_COLOR} If you have a cluster already added to the mesh you have in this project, please delete the cluster and run this script again."
#echo "If you have additional questions, please feel free to reach out to us at csm-users@googlegroups.com"
#echo "The script output is saved at ${LOG_PATH}"
#echo "Before we start, please confirm:"
#echo "  This project ${PROJECT_ID} is the project you used in the CSM Alpha sign up form."
#read -p "Confirm (y/N):" confirm

#shopt -s nocasematch
#if [[ ${confirm} != y ]]; then
#  echo "Aborting!"
#  exit 1
#fi

cluster_exists="Y"
use_existing_cluster="Y"
#while [[ ${cluster_exists} == "Y" && ${use_existing_cluster} == "N" ]]; do
#  CLUSTER=""
#  while [[ ! ${CLUSTER} =~ ^[a-zA-Z0-9_-]+$ ]]; do
#    read -e -p "Enter the cluster name to create [csm-demo]:" CLUSTER
#    CLUSTER=${CLUSTER:-"csm-demo"}
#  done
#  ZONE=""
#  while ! check_zone ${ZONE}; do
#    read -e -p "Enter the cluster zone [us-central1-c]:" ZONE
#    ZONE=${ZONE:-"us-central1-c"}
#  done
#  # only check if cluster exists when the GKE API is enabled
#  if [[ -n $(set -x; gcloud services list --format 'value(config.name)' --filter "config.name=container.googleapis.com") ]]; then
#    if [[ -n $(set -x; gcloud container clusters list --filter "name=${CLUSTER} AND location=${ZONE}" --format 'value(selfLink)') ]]; then
#      echo "Cluster ${CLUSTER} in zone ${ZONE} already exists. Installing CSM on an existing cluster can work in some scenarios, but is not well supported."
#      echo "In particular, please do not try to do this on clusters that are using the Istio on GKE add-on."
#      echo "Given the risks behind this option, we suggest discussing your situation with the CSM team before using it."
#      read -e -p "Are you sure you want to install CSM on this existing cluster? (y/N) [N]:" use_existing_cluster
#      use_existing_cluster=${use_existing_cluster:-"N"}
#    else
#      cluster_exists="N"
#    fi
#  else
#    cluster_exists="N"
#  fi
#done

ENABLE_MANAGED_CA="N"
#while [[ ! ${ENABLE_MANAGED_CA} =~ ^(y|Y|n|N)$ && ${use_existing_cluster} == "N" ]]; do
#  read -e -p "Do you want to use CSM managed certificates? With this option, the GKE cluster created will be deleted after 30 days. (Y/n) [Y]:" ENABLE_MANAGED_CA
#  ENABLE_MANAGED_CA=${ENABLE_MANAGED_CA:-"Y"}
#done

ENABLE_IAP="N"
#while [[ ! ${ENABLE_IAP} =~ ^(y|Y|n|N)$ ]]; do
#  read -e -p "Do you want to have an Identity-Aware Proxy (IAP) installed on your cluster? This option needs manual steps at the end. (y/N) [N]:" ENABLE_IAP
#  ENABLE_IAP=${ENABLE_IAP:-"N"}
#done

INSTALL_APP="N"
#while [[ ! ${INSTALL_APP} =~ ^(y|Y|n|N)$ ]]; do
#  read -e -p "Do you want to have an example application installed at the end? (Y/n) [Y]:" INSTALL_APP
#  INSTALL_APP=${INSTALL_APP:-"Y"}
#done



#echo -e "${C_GREEN}Congratulations! The setup is now complete.${NO_COLOR}"
#echo -e "${C_GREEN}To view your services and metrics, you can now go to the CSM UI here:${NO_COLOR}"
#echo
#echo -e "${C_CYAN}https://console.cloud.google.com/services${NO_COLOR}"
#echo
#shopt -s nocasematch
#if [[ ${INSTALL_APP} == y && ${SAMPLE_APP_URL} != "" ]]; then
#  echo -e "${C_GREEN}You can also visit your sample bookinfo application at the following URL to generate some traffic for your mesh: (It may take a couple minutes for the page to show up, if it does not show up, please contact csm-users@googlegroup.com) ${NO_COLOR}"
#  echo -e "${C_CYAN}${SAMPLE_APP_URL}${NO_COLOR}"
#fi
#if [[ ${ENABLE_IAP} == y ]]; then
#  echo -e "${C_YELLOW}To continue your IAP setup, please follow the [Configuring secure human access using IAP] section in the user guide.${NO_COLOR}"
#fi
#if [[ $mtls_enabled == false ]]; then
#  echo -e "${C_YELLOW}Mutual TLS is disabled, but can be enabled. See https://istio.io/help/faq/security/#enabling-disabling-mtls.${NO_COLOR}"
#fi
#echo -e "${C_GREEN}If you have questions and/or feedback, please email csm-users@googlegroups.com${NO_COLOR}"
