

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


# Fastforward changes
cp $BASE_DIR/labs/platform/config/tf/* $WORK_DIR/tf


# Provision
cd $WORK_DIR/tf 
./tf-up.sh

# Rename Local Contexts
DEFAULT_ZONE="us-central1-c"
SECONDARY_ZONE="us-west1-b"
kubectl config rename-context gke_${PROJECT}_${DEFAULT_ZONE}_boa-prod-primary prod1
kubectl config rename-context gke_${PROJECT}_${SECONDARY_ZONE}_boa-prod-secondary prod2
kubectl config rename-context gke_${PROJECT}_${DEFAULT_ZONE}_boa-stage stage

# Register Secondary cluster with Hub
export GKE_CONNECT_SA=gke-connect-sa
export GKE_CONNECT_SA_FILE=$BASE_DIR/workdir/$GKE_CONNECT_SA-creds.json
gcloud iam service-accounts create $GKE_CONNECT_SA --project=$PROJECT
gcloud iam service-accounts keys create $GKE_CONNECT_SA_FILE \
--project=$PROJECT \
--iam-account=$GKE_CONNECT_SA@$PROJECT.iam.gserviceaccount.com 
GKE_CLUSTER=us-west1-b/boa-prod-secondary
gcloud container hub memberships register boa-prod-secondary \
--project=$PROJECT \
--gke-cluster=$GKE_CLUSTER \
--service-account-key-file=$GKE_CONNECT_SA_FILE

# Register Stage cluster with Hub
export GKE_CONNECT_SA=gke-connect-stage
export GKE_CONNECT_SA_FILE=$BASE_DIR/workdir/$GKE_CONNECT_SA-creds.json
gcloud iam service-accounts create $GKE_CONNECT_SA --project=$PROJECT
gcloud iam service-accounts keys create $GKE_CONNECT_SA_FILE \
--project=$PROJECT \
--iam-account=$GKE_CONNECT_SA@$PROJECT.iam.gserviceaccount.com 
GKE_CLUSTER=us-central1-c/boa-stage
gcloud container hub memberships register boa-stage \
--project=$PROJECT \
--gke-cluster=$GKE_CLUSTER \
--service-account-key-file=$GKE_CONNECT_SA_FILE