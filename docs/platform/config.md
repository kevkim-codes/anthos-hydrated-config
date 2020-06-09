# Managing Configurations

## GitOps & Repository Syncing

## Abstract Namespaces

## Cluster Selectors

## Namespace Isolation

## Drift Management

---
## Lab

At the end of the last section you were left with the following running in your project. 

- Prod-primary cluster (prod1): ACM installed with Terraform
- Prod-secondary cluster (prod2): No ACM installed
- Stage cluster: You added terraform code to create the cluster and install ACM

In this next section you will install ACM manually on prod-secondary then utilize the features of Anthos Config Manager

### Prerequisites

If you completed the previous exercise, skip this step as your project will already be setup. 

If you did not complete the previous section, the following steps will setup a project to the state needed in this section. 

Clone the repository onto your local computer and change into the directory.

```shell
git clone sso://user/crgrant/anthos-workshop -b v2
cd anthos-workshop
```

Set global variables that are used throughout the workshop

```shell
BASE_GIT_URL=https://github.com/YOUR_ID
BASE_DIR=$(PWD)
PROJECT=$(gcloud config get-value project)
```
 


Create Cluster Config Repo

- [ ] TODO: Create Cluster Config Repo

```shell
mkdir $BASE_DIR/workdir
cd $BASE_DIR/workdir
git clone https://github.com/cgrant/cluster_config
```

Install Terraform

- [ ] TODO: Terraform install instructions

Provision Base Infrastructure


```shell

cd $BASE_DIR/labs/platform/config/tf
terraform init
terraform apply

```
This will create 3 clusters: prod-primary, prod-secondary and stage then pull the contexts locally for each so you can interact via `kubectl`. 

It will also install anthos components on prod-primary and stage. You will manually enable components on prod-secondary later in this section. 

For convince we'll rename the clusters to shorter names of: prod1, prod2, stage

```shell
DEFAULT_ZONE="us-central1-c"
SECONDARY_ZONE="us-west1-b"

kubectl config rename-context gke_${PROJECT}_${DEFAULT_ZONE}_boa-prod-primary prod1
kubectl config rename-context gke_${PROJECT}_${SECONDARY_ZONE}_boa-prod-secondary prod2
kubectl config rename-context gke_${PROJECT}_${DEFAULT_ZONE}_boa-stage stage
```

**  Add Stage to Environ **

### Split Screens
To watch the changes more easily it's helpful to have 2 terminals open side by side.  There are multiple ways to accomplish this. 

=== "Cloud Shell"
    In Cloud Shell you can use a popular command line called utility tmux natively to multiplex your Cloud Shell window. In Cloud Shell, tmux commands are initiated with the Ctrl+B key combination. This tells tmux to listen to the next input as its command. Any time you interact with tmux you'll start with the Ctrl+B combination followed by the action you want tmux to perform. Let's see this in practice.

    In your Cloud Shell, type Ctrl+B then % (shift-5).

    You should now see a split screen.

    In this view you can see the left pane is active where the cursor is identified.


    To navigate between the two panes type Ctrl+B then left or right arrow

=== "VS Code"
    VS Code provides the ability to split your terminal in the terminal tool bar on the right. Just to the left of the trash icon you'll find the split screen icon. Click it to utilize multiple panes in the same view. To navigate between panes simply click in the desired pane to activate focus. 

=== "Other"

    You can simply open a second window in your terminal of choice, then place the two windows side by side. This will allow you to execute commands in one window while seeing the results in the other

### Watch the resources

This command utilizes the `watch` command to continuously display command results. In the right terminal pane, execute teh following command

```shell
watch \
    "echo '## Prod1 Namespaces ##'; \
    kubectl --context prod1 get ns; \
    echo '\n\n## Prod2 Namespaces##'; \
    kubectl --context prod2 get ns; \
    echo '\n## bank-of-anthos pods on Prod2 ##'; \
    kubectl --context prod2 get po -n bank-of-anthos"
```

This will list the Namespaces for both Prod1 and Prod2. You should notice the `bank-of-anthos` namesepace exists only in Prod1. You'll also see a list of pods running in the `bank-of-anthos` namespace on Prod2. Since there is no namespace matching that yet, no resources are displayed. 

### Install Anthos ConfigManager 

Config Manager utilizes 2 components to function. First is an operator that manages the various functions and clusters. The second component is the configuration about the repo to sync with. In this section you'll install these components on the prod-secondary

Choose one of the following methods below

=== "Console"

    - [ ] TODO: Add Console instructions

=== "gcloud"

    In this first step we'll retrieve the operator manifest and install the it on the prod-secondary cluster.

    ```shell
    cd $BASE_DIR/labs/platform/config

    gsutil cp gs://config-management-release/released/latest/config-management-operator.yaml config-management-operator.yaml

    kubectl --context prod2 apply -f config-management-operator.yaml

    ```

    Apply the Repo Configuration


    Now that the operator is installed you'll configure it to watch your git repository. First review the ConfigManagement resource we're about to apply. Open the `acm-repo.yaml` file or run the command below to view its contents. 

    First switch your focus to the left terminal pane. 

    ```shell
    cat $BASE_DIR/labs/platform/config/acm-repo.yaml
    ```

    You'll be able to see the git repository we're syncing to, the branch and directory we want applied. In this case we're using a public repository so secretType is set to `none`

    Now execute the following command

    ```shell

    kubectl --context prod2 apply -f $BASE_DIR/labs/platform/config/acm-repo.yaml

    ```

    In just a moment you should see the bank-of-anthos namespace show up in prod2 and resources start creating within the namespace. 



### Create a Namespace

In this step you'll create a namespace, commit it to the repository and watch it apply to both clusters

```shell
cd $BASE_DIR/workdir/cluster_config/
NS=nginx

mkdir sample/namespaces/${NS}
cat <<EOF > sample/namespaces/${NS}/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ${NS}
  labels: 
    istio-injection: enabled
EOF

git add . && git commit -m "new NS" && git push origin stage

```

### Config Drift Management

In this step you'll see how ACM manages configuration drift automatically within your clusters. If a resource is changed inside the cluster without flowing through the designated repository, ACM will revert the changes and reapply the affected resources. 

Watch the resource window carefully in these steps as the change happens quickly. 

Delete the Namespace you just created
```shell
kubectl delete ns ${NS}
```
Almost immediately ACM replaces the namespace.

Try again, this time deleting a pod
```shell
kubectl delete deployment contacts -n bank-of-anthos
```
Notice the replacement pod being created

### NS Isolation

In this next step you'll touch on some safety features in ACM. Typically when running `kubectl apply` the resource manifests can include data indicating which namespace they should be deployed to. This can become a security concern if a resource contained within a folder for one namespace, indicates it should be deployed to a different namespace. Naive deployment engines would simply apply the resource, allowing teams to modify resources in different namespaces.

ACM will not allow resources from one namespace folder to be deployed to a different namespace

You'll try to apply a resource contained within the ${NS} namespace to the bank-of-anthos namespace. Review `$BASE_DIR/labs/platform/config/nginx.yaml`. Notice the namespace listed is bank-of-anthos.

```
apiVersion: apps/v1 
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: bank-of-anthos
...
```

Move that file into the ${NS} directory and push it to the repo

```shell
cp $BASE_DIR/labs/platform/config/nginx.yaml $BASE_DIR/workdir/cluster_config/sample/namespaces/${NS}
git add . && git commit -m "adding nginx" && git push origin stage
```

You'll notice the resource is not deployed to bank-of-anthos namespace, or nginx namespace. ACM blocks the deploy of that resource. 


## Resources
