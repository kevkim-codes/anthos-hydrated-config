


# Provision Clusters

```shell

export GOOGLE_CREDENTIALS=$(< /Users/crgrant/dev/demos/app-pipeline/service.json)
cd tf
tf init
tf apply

```

# Register Cluster
Through UI at https://console.cloud.google.com/anthos/clusters
Show External registration


---
The example utilizes Terraform to provision the clusters. Terraform also configures Anthos config manager on those clusters which

# Prerequisites

- Terraform
- Config Repo already created and accessible


# Setup process


Edit `provision/terraform.tfvars` set appropriate variables


```shell
cd provision/
tf init && tf apply
```

This will

- Enable apis
- Create 3 clusters `prod`, `stage`, `dev`
- Install ACM operator & config-sync on stage & prod cluster

