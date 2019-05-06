# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



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
