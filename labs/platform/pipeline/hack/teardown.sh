
## TODO - clean up isn't parsing APP_NAME in rm -rf

echo ${APP_NAME}
break
cd ../remote_repos/
git clone https://github.com/cgrant/cluster_config.git 
cd cluster_config/
git checkout master
rm -rf sample/namespaces/${APP_NAME}
git add . && git commit -m "created app: ${APP_NAME}" && git push origin master
git checkout stage
rm -rf sample/namespaces/${APP_NAME}
git add . && git commit -m "created app: ${APP_NAME}" && git push origin stage

cd ../../hack

rm -rf ../remote_repos/*
rm -rf ../hydrate_workspace/*
