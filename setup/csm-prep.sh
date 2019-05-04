



check_account_role

check_install_tools
enable_gcp_apis
create_alpha_svc_acct
create_sync_agent_svc_acct
create_mesh
if [[ ${ENABLE_MANAGED_CA} == y ]]; then
  create_fsa
  setup_gcloud_gke_alpha_api
  create_mpi_gke_cluster
else
  create_gke_cluster
fi
install_helm
download_istio
install_istio_control_plane
install_stackdriver_adapter
install_csm_sync_agent
create_sync_agent_secret
verify_sync_agent
install_csm_insights
verify_csm_insights
if [[ ${ENABLE_IAP} == y ]]; then
  iap_create_firewall_rules
fi
if [[ ${INSTALL_APP} == y ]]; then
  deploy_test_bookinfo_app
fi
cleanup
