

BASE_NAME=${1:-"sample"} 


# app-templates

cd app-templates
git init
gh repo create ${BASE_NAME}-app-templates
git add . && git commit -m "initial commit" && git push origin master
rm -rf .git
cd ..

# base-config

cd base-config
git init
gh repo create ${BASE_NAME}-base-config
git add . && git commit -m "initial commit" && git push origin master
rm -rf .git
cd ..

# hydrated-config

cd hydrated-config
git init
gh repo create ${BASE_NAME}-hydrated-config
git add . && git commit -m "initial commit" && git push origin master
rm -rf .git
cd ..