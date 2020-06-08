


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

