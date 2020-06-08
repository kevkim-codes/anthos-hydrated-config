
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

