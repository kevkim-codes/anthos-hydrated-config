

## Steps 



### Set some Vars
```shell
gcloud auth configure-docker

WORKDIR=${PWD}/../hydrate_workspace/
ACM_REPO_NAME=cluster_config
ACM_PATH=sample
APP_NAME=golang-app1
TARGET_ENV=stage
IMAGE_REPO=gcr.io/crg-gcp

```

### Checkout
```
git clone https://github.com/cgrant/${APP_NAME}.git ${WORKDIR}/${APP_NAME}
git clone https://github.com/cgrant/${APP_NAME}-env.git ${WORKDIR}/${APP_NAME}-env
git clone https://github.com/cgrant/shared-kustomize.git ${WORKDIR}/shared-kustomize
git clone https://github.com/cgrant/${ACM_REPO_NAME}.git ${WORKDIR}/${ACM_REPO_NAME}
```

### Build
```
cd ${WORKDIR}/${APP_NAME}
COMMIT_SHA=$(git rev-parse --short HEAD)
docker build --tag ${IMAGE_REPO}/${APP_NAME}:${COMMIT_SHA} .
docker push ${IMAGE_REPO}/${APP_NAME}:${COMMIT_SHA}

IMAGE_SHA=$(gcloud container images describe ${IMAGE_REPO}/${APP_NAME}:${COMMIT_SHA} --format='value(image_summary.digest)')

```

### Hydrate
```shell

cd ${WORKDIR}/${APP_NAME}-env
git checkout ${TARGET_ENV}
cd ${WORKDIR}/${APP_NAME}/k8s/${TARGET_ENV}
# use Git Commit sha
# kustomize edit set image app=${IMAGE_REPO}/${APP_NAME}:${COMMIT_SHA}
#IMAGE_ID=${COMMIT_SHA}
# -OR- 
# use image sha
kustomize edit set image app=${IMAGE_REPO}/${APP_NAME}@${IMAGE_SHA}
IMAGE_ID=${IMAGE_SHA}
kustomize build . -o ${WORKDIR}/${APP_NAME}-env/${TARGET_ENV}/${APP_NAME}.yaml
cd ${WORKDIR}
```

### Consolidate in ACM (Optional)
cp ${WORKDIR}/${APP_NAME}-env/${TARGET_ENV}/${APP_NAME}.yaml \
    ${WORKDIR}/${ACM_REPO_NAME}/${ACM_PATH}/namespaces/${APP_NAME}/${APP_NAME}.yaml


### Push Env &OR ACM Repos

cd ${WORKDIR}/${APP_NAME}-env
git add ${TARGET_ENV}/${APP_NAME}.yaml && git commit -m "Updating image to ${IMAGE_ID}"
git push origin stage
cd ${WORK_DIR}








### Argo

```shell
# get argo endpoint
ARGOCD_SERVER=$(kubectl get svc argocd-server -n argocd)

# Get the password
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2

# Login w/ cli
#    user: admin
argocd login $ARGOCD_SERVER

# Create the app
argocd app create ${APP_NAME} \
    --repo https://github.com/cgrant/${APP_NAME}-env.git \
    --revision ${TARGET_ENV} \
    --path ${TARGET_ENV} \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace ${APP_NAME} \
    --sync-policy automated

```

