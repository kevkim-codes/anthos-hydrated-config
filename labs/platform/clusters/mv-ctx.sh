

DEFAULT_ZONE="us-central1-c"
SECONDARY_ZONE="us-west1-b"

kubectl config rename-context gke_${PROJECT}_${DEFAULT_ZONE}_boa-prod-primary prod1
kubectl config rename-context gke_${PROJECT}_${SECONDARY_ZONE}_boa-prod-secondary prod2
kubectl config rename-context gke_${PROJECT}_${DEFAULT_ZONE}_boa-stage stage