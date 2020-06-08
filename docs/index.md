# Anthos Workshop V2 - Section-1 Platform



## Clusters
- Prep:
    - Env Vars: project_id

- Create Config-sync repo
- Provision Clusters w/ Terraform
    - Create 2 clusters 
    - Use TF to install ACM synced on primary
- Register Secondary Cluster in Environ
- Review TF code for ACM & ASM


## Config Management
- Prep:
    - Cluster (prod2) with no operator or acm sync
    - Env Vars: project_id

- Configure Sync to Repo
- Experience Gitops (Write to repo)
    - Review Abstract Namespaces
    - New Namespace (under abstract NS)
- NS Isolation
- Implement Cluster Selectors
- Config Drift Management

## ASM
- Prep:
    - Cluster (prod2) with ASM
    - Hipster or BOA deployed 
    - Env Vars: project_id

- Review Topology view
- Review SRE Metrics
- Set SLO & Review alert
- Review Service Logs

## Pipelines
- Prep: 
    - Config Sync Repo
    - Cluster (stage) synced to config-sync repo
    - Env Vars: project_id, Github locations

- Create Repos
    - base-config
    - app-templates
- Create New App
- Kustomize for stage  
- Deploy first services





Topics

- Scalable Delivery Pipeline
- Interface Contracts
- Hydrating with Kustomize
- Pipeline Git Repositories

Tasks

- Setup 
    - Provision Clusters
    - Anthos Pipeline
- Create new App
- Deploy first services
- Update services
- Implement Canary

Prerequisites
- Terraform
- gh cli
- github user name (set in variable)

---

The Anthos Application Pipeline is a scalable framework for managing services across multiple life cycles and clusters

In this example we'll look at the various components comprising the Anthos Application Pipeline. The overall pipeline is divided into 4 main elements, Repositories, Development, Hydration, and Deployment. 


The framework focuses on 3 primary personas common in enterprise architectures. First is the Platform administrator who create and manage the cloud infrastructure thats most used by the app teams. ...

