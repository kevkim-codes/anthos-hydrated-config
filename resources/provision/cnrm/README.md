

## Create
mkdir anthos

#kpt pkg init anthos
kpt pkg init anthos --description "anthos bootstrap"

# Create simple setters
# in the folder "anthos" create a variable "gcloud.container.cluster"
#           Then annontate any line in the yamls that has the string asm-cluster
kpt cfg create-setter anthos/ gcloud.container.cluster  asm-cluster

kpt cfg create-setter anthos/ gcloud.core.project google-project 
## required not working
## kpt cfg create-setter anthos/ gcloud.core.project google-project --required

kpt cfg create-setter anthos/ gcloud.compute.location us-central1-c


## Create a substitution. If the setter isn't found it will create it
## We're reusing gcloud.core.project
kpt cfg create-subst anthos/ \
    clusterName \
    --field-value PROJECT_ID/us-central1-c/asm-cluster \
    --pattern \${gcloud.core.project}/us-central1-c/asm-cluster






## Use
kpt cfg list-setters anthos/
kpt cfg set anthos/ gcloud.core.project ${PROJECT_ID}
## BUG gcloud.core.project ${PROJECT_ID} is setting the substitution but not the direct setters
kpt cfg set anthos/ gcloud.container.cluster bod-demo

anthoscli apply -f anthos 