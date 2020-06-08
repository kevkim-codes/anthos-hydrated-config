# This script emulates the steps needed to instantiate a new applicaiton

# usage ./create-app.sh <app-language> <app-name>

APP_LANG=${1:-"golang"} 
APP_NAME=${2:-"my_app"} 
APP_NAME=$REPO_PREFIX-$APP_NAME

# Create an instance of the template.
cd $WORK_DIR/
git clone $GIT_BASE_URL/${REPO_PREFIX}-app-templates
cd ${REPO_PREFIX}-app-templates/${APP_LANG}-template
find . -name kustomization.yaml -exec sed "s/namePrefix:.*/namePrefix: '${APP_NAME}'/g" {} \;
find . -name kustomization.yaml -exec sed "s/  app:.*/  app: '${APP_NAME}'/g" {} \;
git init
gh repo create ${APP_NAME}
git add . && git commit -m "initial commit" && git push origin master
cd $BASE_DIR
rm -rf $WORK_DIR/${REPO_PREFIX}-app-templates


# Create the cluster config namespace
cd $WORK_DIR/hydrated-config
git checkout master
mkdir namespaces/${APP_NAME}
cat <<EOF > namespaces/${APP_NAME}/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ${APP_NAME}
  labels: 
    istio-injection: enabled
EOF
git add . && git commit -m "created app: ${APP_NAME}" && git push origin master

git branch stage || git checkout stage
mkdir namespaces/${APP_NAME}
cat <<EOF > namespaces/${APP_NAME}/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ${APP_NAME}
  labels: 
    istio-injection: enabled
EOF
git add . && git commit -m "created app: ${APP_NAME}" && git push origin stage
