# This script emulates the steps needed to instantiate a new applicaiton

# usage ./create-app.sh <app-name>


APP_NAME=${1:-"my_app"} 

# Create an instance of the template.
#    In practice this would then create a remote repo and push the contents up
cp -r ../starter_repos/golang-template ../remote_repos/${APP_NAME}
cd ../remote_repos/${APP_NAME}
git init
gh repo create ${APP_NAME}
git add . && git commit -m "initial commit" && git push origin master
cd ../../hack

# Create the app-env
#    In practice this would then create a remote repo and push the contents up
cp -r ../starter_repos/env-template ../remote_repos/${APP_NAME}-env
cd ../remote_repos/${APP_NAME}-env
git init
gh repo create ${APP_NAME}-env
git add . && git commit -m "initial commit" && git push origin master
cd ../../hack

# Create the cluster config namespace
cd ../remote_repos/
git clone https://github.com/cgrant/cluster_config.git 
cd cluster_config/
git checkout master
mkdir sample/namespaces/${APP_NAME}
cat <<EOF > sample/namespaces/${APP_NAME}/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ${APP_NAME}
  labels: 
    istio-injection: enabled
EOF
git add . && git commit -m "created app: ${APP_NAME}" && git push origin master

git checkout stage
mkdir sample/namespaces/${APP_NAME}
cat <<EOF > sample/namespaces/${APP_NAME}/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ${APP_NAME}
  labels: 
    istio-injection: enabled
EOF
git add . && git commit -m "created app: ${APP_NAME}" && git push origin stage
