
# Create config repo
cp -R $BASE_DIR/resources/repos/hydrated-config $WORK_DIR
cd $WORK_DIR/hydrated-config
git init && git add . && git commit -m "initial commit"
$BASE_DIR/labs/common/gh.sh create $REPO_PREFIX-hydrated-config  
git remote add origin $GIT_BASE_URL/$REPO_PREFIX-hydrated-config
git push origin master
cd $BASE_DIR

# Create Terraform directory
cp -R $BASE_DIR/resources/provision/start $WORK_DIR/tf