

DEFAULT_ZONE="us-central1-c"
SECONDARY_ZONE="us-west1-b"
BASE_NAME="gke_${PROJECT}_"

kubectl config rename-context gke_${PROJECT}_${DEFAULT_ZONE}_boa-prod-primary prod1
kubectl config rename-context gke_${PROJECT}_${SECONDARY_ZONE}_boa-prod-primary prod2
kubectl config rename-context gke_${PROJECT}_${DEFAULT_ZONE}_boa-prod-primary stage