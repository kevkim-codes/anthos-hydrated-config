# Environments & Clusters
 
### Objectives
Multi Cluster Use Cases 
Cluster Organization Best Practices
Working with Projects, Hub & Environs
Provisioning Platform Resources

## Before you begin
To get started with this lab you’ll need to install tooling, set a few variables and provision the environment. Follow the steps below to prepare your lab.

### Task: Install Tools

- Terraform
- GitHub's cli gh

### Task: Clone Lab Repository
Clone the repository onto your local computer and change into the directory.

```shell
git clone sso://user/crgrant/anthos-workshop -b v2
cd anthos-workshop
```

### Task: Set Lab Variables

Set global variables that are used throughout the workshop

```shell
export GIT_ID=YOUR_ID #UPDATE WITH YOUR ID
export GIT_BASE_URL=https://github.com/${GIT_ID}
export REPO_PREFIX="anthos"
export ACM_REPO=${GIT_BASE_URL}/$REPO_PREFIX-hydrated-config


export PROJECT=$(gcloud config get-value project)
export BASE_DIR=$(PWD)
export WORK_DIR=${BASE_DIR}/workdir
mkdir -p $WORK_DIR
```
 
### Task: Prepare the workspace

```shell
source $BASE_DIR/labs/platform/clusters/prep.sh
```


## Provisioning Resources
### Task: Create an Anthos Cluster
 
Add the lines from both cluster.tf & acm.tf listed below to the appropriate files located in `$BASE_DIR/workdir/tf`

=== "cluster.tf"
    ```terraform

    # Provision Secondary Cluster
    resource "google_container_cluster" "prod-secondary" {
        name               = "${var.gke_name}-prod-secondary"
        location           = var.secondary_zone
        initial_node_count = 4
        depends_on = [google_project_service.container]

    }
    
    # Retrieve Cluster Credentials
    resource "null_resource" "configure_kubectl_prod-secondary" {
        provisioner "local-exec" {
            command = "gcloud container clusters get-credentials ${google_container_cluster.prod-secondary.name} --zone ${google_container_cluster.prod-secondary.location} --project ${data.google_client_config.current.project}"
        }
        depends_on = [google_container_cluster.prod-secondary]
    }
    ```

=== "acm.tf"
    ```terraform

    # Enable Anthos Configuration Management
    module "acm-prod-secondary" {
        source           = "terraform-google-modules/kubernetes-engine/google//modules/acm"
        skip_gcloud_download = true

        project_id       = data.google_client_config.current.project
        cluster_name     = google_container_cluster.prod-secondary.name
        location         = google_container_cluster.prod-secondary.location
        cluster_endpoint = google_container_cluster.prod-secondary.endpoint

        operator_path    = var.acm_operator_path
        sync_repo        = var.acm_repo_location
        sync_branch      = "master"
        policy_dir       = "."
    }

    ```


### Task: Provision Resources

```shell
cd $WORK_DIR/tf 
./tf-up.sh
```

This will create 3 clusters: prod-primary, prod-secondary and stage then pull the contexts locally for each so you can interact via `kubectl`. 

It will also install anthos components on prod-primary. You will manually enable components on the others in later steps. 

### Task: Rename Contexts
For convince we'll rename the clusters to shorter names of: prod1, prod2, stage

```shell
DEFAULT_ZONE="us-central1-c"
SECONDARY_ZONE="us-west1-b"

kubectl config rename-context gke_${PROJECT}_${DEFAULT_ZONE}_boa-prod-primary prod1
kubectl config rename-context gke_${PROJECT}_${SECONDARY_ZONE}_boa-prod-secondary prod2
kubectl config rename-context gke_${PROJECT}_${DEFAULT_ZONE}_boa-stage stage
```




## Working with Environs

Cluster Organization Best Practices

### Task: Register With Anthos Hub
To add a cluster to an Anthos Environ the following steps need to be performed:

- Create a service account (SA) to connect the agent with Google
- Register the Cluster & SA with Anthos Environ

Once the data has been submitted, Anthos will


=== "Console"
    
    Click on Anthos -> Clusters from the left navigation

    ![](../images/platform/anthos-clusters-nav.png)

    Click on `Register Existing Cluster` from the top navbar

    ![](../images/platform/anthos-clusters-register.png)

    Now click the `Register` button next to the `boa-prod-secondary` cluster

    ![](../images/platform/anthos-clusters-register-secondary.png)
    
    Deselect the `Download new service key` option and click `Submit`

    ![](../images/platform/anthos-clusters-register-secondary-submit.png)

    Once all the steps have completed click `Done`



=== "gcloud"
    Create a service account
    ```shell
    export GKE_CONNECT_SA=gke-connect-sa
    export GKE_CONNECT_SA_FILE=$WORK_DIR/$GKE_CONNECT_SA-creds.json
    gcloud iam service-accounts create $GKE_CONNECT_SA --project=$PROJECT
    ```

    Create & download a key
    ```shell
    gcloud iam service-accounts keys create $GKE_CONNECT_SA_FILE \
    --project=$PROJECT \
    --iam-account=$GKE_CONNECT_SA@$PROJECT.iam.gserviceaccount.com 
    ```


    Register with hub

    ```shell
   
    GKE_CLUSTER=us-west1-b/boa-prod-secondary

    gcloud container hub memberships register boa-prod-secondary \
    --project=$PROJECT \
    --gke-cluster=$GKE_CLUSTER \
    --service-account-key-file=$GKE_CONNECT_SA_FILE

    ```

    Confirm Registration by running

    ```shell
    gcloud container hub memberships list
    ```
    Output
    <pre>
    NAME                EXTERNAL_ID
    boa-prod-secondary  e0f007ef-a9e6-11ea-88fb-42010a8a0002
    </pre>


### Cleanup

If you're continuing on with the next lesson, skip this step, you'll use the resources in the next lab. 

However if you'd like to teardown your environment simply run
```shell
cd $WORK_DIR/tf 
./tf-down.sh
```

## Resources

- [Anthos Technical Overview](https://cloud.google.com/anthos/docs/concepts/overview)
- [Anthos Environs](https://cloud.google.com/anthos/multicluster-management/environs)
- [Terraform GKE ACM Submodule](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/8.1.0/submodules/acm)
- [Terraform GKE ASM Submodule](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/add-asm-module/modules/asm)
- [Register a cluster](https://cloud.google.com/anthos/multicluster-management/connect/registering-a-cluster)

