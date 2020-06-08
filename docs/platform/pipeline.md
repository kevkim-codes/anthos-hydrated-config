# Integrated Pipelines


## Scalable Delivery Pipeline
## Interface Contracts
## Defining the Repositories


The pipeline is designed to support a large number of applications with minimal overhead. To enable this, the framework suggests 4 types of repositories. 

**App Templates**:

- A set of repositories is included in the overall pipeline to act as of templates for common application languages. These repos contain base code, k8s yamls, and ci/cd configs to help teams bootstrap new applications in the pipeline. New applications copy from this set of resources once upon creation. 

**App Repo**:

- The traditional source repositories used by the application teams to store code and other assets. These also contain resource yaml overrides unique to the application and/or environment

**Base Config Repo**:

- Base yaml configurations used by all applications. The applications pull in these base configurations to create fully formed deeployment yamls. These minimize the amount of configuration managed by the app teams and centralizes common patterns like labeling. 

**Hydrated Config Repo**:

- This repository contains the yamls that represent the desired state of the clusters. The clusters apply the k8s yamls in this repo during the deploy process. This may be represented by one or more repositories depending on your usage of the framework. For example utilizing ACM for config and deploy resources will use one repository. Utilizing ACM for config and separate tool for deploy you might utilize a separate repo for that tool. 

- The hydrated config repo(s) stores configs separately per environment (dev/stage/prod). A pattern is shown in this example utilizing branches but other patterns utilizing folders or separate repos are just as effective. 


## Hydrating with Kustomize




