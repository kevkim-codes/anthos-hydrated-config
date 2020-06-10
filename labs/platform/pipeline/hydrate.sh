# Hydrate

# This script emulates the activities that are triggered by a git commit or merge. 

### Set some Vars
gcloud auth configure-docker
APP_NAME=${1:-"my_app"} 
TARGET_ENV=stage
IMAGE_REPO=gcr.io/${PROJECT}


### Build

cd $WORK_DIR/cicd_workspace/${APP_NAME}
COMMIT_SHA=$(git rev-parse --short HEAD)
docker build --no-cache --tag ${IMAGE_REPO}/${APP_NAME}:${COMMIT_SHA} .
docker push ${IMAGE_REPO}/${APP_NAME}:${COMMIT_SHA}
IMAGE_SHA=$(gcloud container images describe ${IMAGE_REPO}/${APP_NAME}:${COMMIT_SHA} --format='value(image_summary.digest)')


### Hydrate 
#     - Repeat for all environments (currently only executing stage)
cd ${WORK_DIR}/cicd_workspace/${REPO_PREFIX}-hydrated-config
git branch ${TARGET_ENV} || git checkout ${TARGET_ENV}

cd ${WORK_DIR}/cicd_workspace/${APP_NAME}/k8s/${TARGET_ENV}
## use Git Commit sha
## kustomize edit set image app=${IMAGE_REPO}/${APP_NAME}:${COMMIT_SHA}
## IMAGE_ID=${COMMIT_SHA}
## -OR- 
## use image sha
kustomize edit set image app=${IMAGE_REPO}/${APP_NAME}@${IMAGE_SHA}
IMAGE_ID=${IMAGE_SHA}


kustomize build . \
  -o ${WORK_DIR}/cicd_workspace/${REPO_PREFIX}-hydrated-config/namespaces/${APP_NAME}/${APP_NAME}.yaml

cd $BASE_DIR

