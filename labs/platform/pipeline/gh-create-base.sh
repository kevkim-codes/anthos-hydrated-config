

REPO_PREFIX=${1:-"anthos"} 


# app-templates

cp -R $BASE_DIR/resources/repos/app-templates $WORK_DIR
cd $WORK_DIR/app-templates
git init
$BASE_DIR/labs/common/gh.sh create ${REPO_PREFIX}-app-templates
git remote add origin $GIT_BASE_URL/${REPO_PREFIX}-app-templates
git add . && git commit -m "initial commit" && git push origin master
cd $BASE_DIR
rm -rf $WORK_DIR/app-templates

# base-config
cp -R $BASE_DIR/resources/repos/base-config $WORK_DIR
cd $WORK_DIR/base-config
git init
$BASE_DIR/labs/common/gh.sh create ${REPO_PREFIX}-base-config
git remote add origin $GIT_BASE_URL/${REPO_PREFIX}-base-config
git add . && git commit -m "initial commit" && git push origin master
rm -rf .git
cd $BASE_DIR
rm -rf $WORK_DIR/base-config

# hydrated-config
# Should already be setup from previous steps
