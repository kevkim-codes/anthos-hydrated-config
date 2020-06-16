terraform destroy -auto-approve \
    -var project_id=${PROJECT} \
    -var acm_operator_path=${BASE_DIR}/resources/acm/config-management-operator.yaml \
    -var acm_repo_location=${ACM_REPO} 

kubectl config unset clusters.prod1
kubectl config unset clusters.prod2
kubectl config unset clusters.stage