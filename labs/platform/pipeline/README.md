# What to demo


Integrated Pipelines
- Setup Anthos  Platform
- Create new App
- Deploy first services
- Update services



---



# Working with repos in this example

The overall framework can work against any git repository. For the purposes of this example we'll be using GitHub and the GitHub CLI `gh`

    NOTE: There is no delete function in this example. You will need to delete repos manually


## Creating foundational repositories
In this step we'll create 3 repositories that will be used throughout the rest of the process. 

You'll create the following repos: 

- app-templates
- base-config
- hydrated-config

In a later step you'll create the fourth type, the application source repo. First let's get the base created. 

Run the following commands

```shell
cd 1-repos
./gh-create-base.sh
```
