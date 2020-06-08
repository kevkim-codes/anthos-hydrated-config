# Hydrate

# This script emulates the activities that are triggered by a git commit or merge. 

### Set some Vars
gcloud auth configure-docker
APP_NAME=${1:-"my_app"} 
WORKDIR=${PWD}/../hydrate_workspace
ACM_REPO_NAME=cluster_config
TARGET_ENV=stage
IMAGE_REPO=gcr.io/crg-gcp

### Checkout Git repos
cd ../hydrate_workspace
git clone https://github.com/cgrant/shared-kustomize.git 
git clone https://github.com/cgrant/cluster_config.git 
git clone https://github.com/cgrant/${APP_NAME}
git clone https://github.com/cgrant/${APP_NAME}-env
cd ../hydrate_workspace

### Build

cd ${WORKDIR}/${APP_NAME}
COMMIT_SHA=$(git rev-parse --short HEAD)
docker build --tag ${IMAGE_REPO}/${APP_NAME}:${COMMIT_SHA} .
docker push ${IMAGE_REPO}/${APP_NAME}:${COMMIT_SHA}
IMAGE_SHA=$(gcloud container images describe ${IMAGE_REPO}/${APP_NAME}:${COMMIT_SHA} --format='value(image_summary.digest)')


### Hydrate


cd ${WORKDIR}/${APP_NAME}-env
git branch ${TARGET_ENV}
git checkout ${TARGET_ENV}
cd ${WORKDIR}/${APP_NAME}/k8s/${TARGET_ENV}
## use Git Commit sha
## kustomize edit set image app=${IMAGE_REPO}/${APP_NAME}:${COMMIT_SHA}
##IMAGE_ID=${COMMIT_SHA}
## -OR- 
## use image sha
kustomize edit set image app=${IMAGE_REPO}/${APP_NAME}@${IMAGE_SHA}
IMAGE_ID=${IMAGE_SHA}
kustomize build . -o ${WORKDIR}/${APP_NAME}-env/${TARGET_ENV}/${APP_NAME}.yaml
cd ../../..


### Consolidate in ACM (Optional)
cp ${WORKDIR}/${APP_NAME}-env/stage/${APP_NAME}.yaml \
    ${WORKDIR}/${ACM_REPO_NAME}/sample/namespaces/${APP_NAME}/${APP_NAME}.yaml


### Push Env &OR ACM Repos

cd ${WORKDIR}/${APP_NAME}-env
git add ${TARGET_ENV}/${APP_NAME}.yaml && git commit -m "Updating image to ${IMAGE_ID}"
git push origin stage
cd ${WORKDIR}/../hack