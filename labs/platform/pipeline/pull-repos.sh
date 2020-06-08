### Set some Vars
gcloud auth configure-docker
APP_NAME=${1:-"my_app"} 
TARGET_ENV=stage
IMAGE_REPO=gcr.io/${PROJECT}

### Create a CI/CD Workspace
mkdir $WORK_DIR/cicd_workspace

### Checkout Git repos
cd $WORK_DIR/cicd_workspace
git clone $GIT_BASE_URL/${REPO_PREFIX}-base-config.git base-config
git clone $GIT_BASE_URL/${APP_NAME}.git
git clone $GIT_BASE_URL/${REPO_PREFIX}-hydrated-config.git 
cd $WORK_DIR