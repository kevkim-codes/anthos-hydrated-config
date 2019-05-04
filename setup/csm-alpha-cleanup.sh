#!/usr/bin/env bash

# Copyright 2019 Google LLC


# This script is provided to the users of CSM Alpha to facilitate their
# onboarding experience. The script deletes the mesh inside the project.
#
# Usage:
# ./csm-alpha-cleanup.sh
#
# Please note the script has ONLY be tested against the GCP Cloud Shell.
#

set -o nounset
set -o pipefail

echo "All executed gcloud, kubectl and gsutil commands are printed out."
echo "Getting some initial values for the script..."
ACCOUNT=$(set -x; gcloud config get-value account 2> /dev/null)
PROJECT_ID=$(set -x; gcloud config get-value project 2> /dev/null)
PROJECT_NUMBER=$(set -x; gcloud projects describe --format='value(projectNumber)' ${PROJECT_ID})
MESH_NAME="projects/${PROJECT_NUMBER}/meshes/${PROJECT_NUMBER}"

C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[1;36m'
C_RED='\033[0;31m'
NO_COLOR='\033[0m'

# Linux cs-6000-devshell is a safe string to check for cloud shell environment
if [[ ! $(uname -a) =~ ^"Linux cs-6000-devshell" ]]; then
  echo -e "${C_RED}Currently the script can only be run in Google Cloud Shell. Please open a cloud shell in your project and try again. If you have additional questions, please contact us at csm-users@googlegroups.com${NO_COLOR}"
  exit 0
fi

# Only supports default gcloud command. Skips user customized version.
GCLOUD_PATH=$(which gcloud)
GCLOUD_VALID="/google/google-cloud-sdk/bin/gcloud"
if [[ ${GCLOUD_PATH} != "${GCLOUD_VALID}" ]]; then
  echo -e "${C_RED}Currently the script only supports the default version of gcloud in Google Cloud Shell which should be installed at ${GCLOUD_VALID}, but got ${GCLOUD_PATH}${NO_COLOR}"
  exit 0
fi

echo "Welcome to CSM Alpha"
echo "Before we start, please confirm:"
echo "  This project ${PROJECT_ID} is the project you used in the CSM Alpha sign up form."
read -p "Confirm (y/N):" confirm

shopt -s nocasematch
if [[ ${confirm} != y ]]; then
  echo "Aborting!"
  exit 1
fi

remove_sa(){
    local sa="${1-}"; shift
    local role_bindings=$(set -x; gcloud projects get-iam-policy ${PROJECT} --flatten "bindings[].members" --filter "bindings.members:${sa}" --format 'value(bindings.role)')
    for rb in ${role_bindings}; do
      (set -x; gcloud projects remove-iam-policy-binding ${PROJECT} --member "serviceAccount:${sa}" --role "${rb}" --quiet --no-user-output-enabled)
    done
    (set -x; gcloud iam service-accounts delete ${sa} --quiet --no-user-output-enabled)
}

delete_mesh() {
  echo -e "${C_RED}The mesh ${MESH_NAME} is going to be deleted if it exists! All of its namespaces and services will be deleted as well. ${NO_COLOR}"
  read -p "Confirm (y/N):" confirm
  if [[ ${confirm} == y ]]; then
    if ! gcloud components repositories list | grep csm-alpha-artifacts > /dev/null; then
      sudo gcloud components repositories add https://storage.googleapis.com/csm-alpha-artifacts/gcloud/components-2.json
      sudo gcloud components update
    fi

    local mesh_state=$(gcloud alpha service-management meshes describe --format='value(lifecycleState)' 2> /dev/null)
    if [[ ${mesh_state} == "ACTIVE" ]]; then
      gcloud alpha service-management meshes delete --recursive
      echo "Waiting for mesh ${MESH_NAME} to be really deleted"
      local check_counter=0
      # Wait for 10 minutes until the mesh is indeed deleted.
      while [[ $check_counter -le 60 ]]
      do
        sleep 10
        ((check_counter+=1))
        if ! gcloud alpha service-management meshes describe > /dev/null 2>&1; then
          echo "The mesh ${MESH_NAME} is deleted successfully"
          break
        fi
      done
    else
      echo "The mesh ${MESH_NAME} doesn't exist"
    fi
  fi
}

# csm alpha cleanup
remove_sa csm-sync-agent@$PROJECT.iam.gserviceaccount.com
remove_sa stackdriver-adapter@$PROJECT.iam.gserviceaccount.com

delete_mesh
