#!/bin/bash


# Tools
mkdir -p $WORK_DIR/bin
export PATH=$PATH:$WORK_DIR/bin:
## Install Kustomize
if ! command -v kustomize 2>/dev/null; then
	echo "Installing kustomize..."
	curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
    mv ./kustomize $WORK_DIR/bin
fi

## Install KPT
if ! command -v kpt 2>/dev/null; then
	echo "Installing kpt..."
	curl -o kpt "https://storage.googleapis.com/kpt-dev/latest/linux_amd64/kpt"
    chmod +x kpt 
    mv ./kpt $WORK_DIR/bin
fi

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


