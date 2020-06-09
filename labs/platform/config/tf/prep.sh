
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