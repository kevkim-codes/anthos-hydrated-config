#!/usr/bin/env bash

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


echo "### "
echo "### Begin Tools install"
echo "### "
# Install Helm
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh &> /dev/null
cp /usr/local/bin/helm $WORK_DIR/bin
rm ./get_helm.sh

# Download Skaffold
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
chmod +x skaffold
mv skaffold $WORK_DIR/bin

# Download Istio
#export ISTIO_VERSION=1.1.1
#curl -L https://git.io/getLatestIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
#cp istio-$ISTIO_VERSION/bin/istioctl $WORK_DIR/bin/.
#mv istio-$ISTIO_VERSION $WORK_DIR/istio

# Install yq.v2
curl -o yq.v2 -OL https://github.com/mikefarah/yq/releases/download/2.3.0/yq_linux_amd64
chmod +x yq.v2
mv yq.v2 $WORK_DIR/bin

# Install kops
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops-linux-amd64
mv kops-linux-amd64 $WORK_DIR/bin/kops

## Install kubectx
curl -LO https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx 
chmod +x kubectx 
mv kubectx $WORK_DIR/bin



# While GKE Hub is in Alpha 
sudo gcloud components repositories add \
  https://storage.googleapis.com/gkehub-gcloud-dist-beta/components-2.json
   sudo gcloud components update
