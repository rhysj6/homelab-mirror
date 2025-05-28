# Clusters
This folder contains all the root terraform modules for provisioning the downstream clusters and managing the core infrastructure of the clusters. 

# Folder Structure
There is a folder for each cluster and in each cluster is two root modules
## cluster
This is the root module for the rancher downstream cluster. It provisions the cluster using the `downstream_cluster` module from the `modules` folder, when there are kubernetes updates, the `downstream_cluster` module will be updated and this module will be re-applied which rancher will then automatically update the cluster.

The only cluster not containing this module is the management cluster since it is manually provisioned using [k3sup](https://github.com/alexellis/k3sup).

## core
This is the root module for the core infrastructure of the cluster. It provisions the core infrastructure using the `core_cluster` module from the `modules` folder, when there are updates to the core infrastructure, the `core_cluster` module will be updated and this module will be re-applied which will then automatically update the core infrastructure of the cluster. These modules have CI and CD pipelines for each cluster, so when changes are made to the modules, the clusters will be updated automatically.