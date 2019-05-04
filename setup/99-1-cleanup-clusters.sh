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



#PROJECT_ID="${PROJECT_ID:?PROJECT_ID env variable must be specified}"
#PROJECT=$PROJECT_ID


#go get gopkg.in/mikefarah/yq.v2
FILES=clusters/*.yaml
for f in $FILES
do
    NAME=$(yq.v2 r $f  metadata.name)
    ZONE=$(yq.v2 r $f  spec.location.zone)
    echo $NAME $ZONE
    
    gcloud container clusters delete ${NAME} -q --zone ${ZONE} --async
    kubectx -d $NAME
done

#kops delete cluster $KOPS_CLUSTER_NAME --state $KOPS_STORE --project=${PROJECT} --yes
