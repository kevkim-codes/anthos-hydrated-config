terraform init
terraform apply -auto-approve \
    -var project_id=${PROJECT} \
    -var acm_operator_path=${BASE_DIR}/resources/acm/config-management-operator.yaml \
    -var acm_repo_location=${ACM_REPO} 

# Rename Contexts
kubectl config rename-context gke_${PROJECT}_${DEFAULT_ZONE}_boa-prod-primary prod1
kubectl config rename-context gke_${PROJECT}_${SECONDARY_ZONE}_boa-prod-secondary prod2
kubectl config rename-context gke_${PROJECT}_${DEFAULT_ZONE}_boa-stage stage