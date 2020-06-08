
TARGET_ENV=stage

### Push Env &OR ACM Repos
cd ${WORK_DIR}/cicd_workspace/${REPO_PREFIX}-hydrated-config
git add . && git commit -m "Updating image to ${IMAGE_ID}"
git push origin ${TARGET_ENV}
cd ${WORK_DIR}