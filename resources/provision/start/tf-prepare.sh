terraform init
terraform prepare \
    -var project_id=${PROJECT} \
    -var acm_operator_path=${BASE_DIR}/resources/acm/config-management-operator.yaml \
    -var acm_repo_location=${ACM_REPO} 

