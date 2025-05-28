# Applications Folder
This folder contains all applications deployed onto kubernetes clusters.

# Folder Structure
There are three main folders in this directory:
- **modules**: Contains all the reusable modules for deploying and configuring applications. In here are folders per application, in some cases it will just be a single module, in other cases, it will be an app module and a config module.
- **clusters**: Provisions all the applications onto the applicable clusters. This uses the simple or app modules defined in the `modules` folder to deploy applications.
- **configs**: Contains all the configurations for the applications deployed on the clusters. This uses the config modules defined in the `modules` folder to configure applications.

The reason why most applications are not deployed directly in the respective cluster root module is to allow for reusability of the modules and to allow for staging of changes, for example if a production application needs to be updated/reconfigured, the changes can be made in the `modules` folder and then applied to the test cluster first, and then to the production cluster. This allows for testing of changes before they are applied to production. I had initially create an env folder for each application, but this was not scalable as the number of applications grew, however, if I were working on a single application in it's own repository, I would use the `env` folder structure.

# Applications not in the modules folder
There are some applications where 
- **observability**: This is a collection of applications that are used as a central observability stack. It is not a single application, but a collection of applications that are used to provide observability for the clusters. It runs on the redcliff cluster for high availability and uses a set of MinIO buckets for storage, so is unlikely to benefit from a staging environment.
- **rancher**: Since rancher is used to manage all clusters and provision downstream clusters, it is only ever deployed on the management cluster. It also needs to authenticate with the management cluster directly rather than using rancher since it manages rancher itself.

# Automated updates
Renovate bot is used to automatically find updates for applications. It will create PRs for each application that needs to be updated. When a PR is created, the CI pipelines will run based on affected folders, so if an application is updated, the CI pipelines for each cluster will run a plan to see if the application is deployed on that cluster and needs to be updated. If the application is deployed on the cluster, the plan will run and show the changes that will be made to the cluster. If the changes are acceptable, the PR can be merged and the changes will be applied to the cluster.

A goal of mine is to configure renovate to automatically merge changes depending on the application and version number change, for example if a patch version is updated, it can be automatically merged, but if a major version is updated, it will require manual intervention. This is not currently configured, but is something I would like to do in the future.