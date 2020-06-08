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


