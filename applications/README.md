# Applications Folder
This folder contains all applications deployed onto kubernetes clusters.

# Folder Structure
There are three main folders in this directory:
-- `modules`: Contains all the reuable modules for deploying and configuring applications. In here are folders per application, in some case cases it will just be a single module, in other cases, it will be an app module and a config module.
-- `clusters`: Contains all the clusters where applications are deployed. This uses the simple or app modules defined in the `modules` folder to deploy applications.
-- `configs`: Contains all the configurations for the applications deployed on the clusters. This uses the config modules defined in the `modules` folder to configure applications.

# Applications not in the modules folder
There are two applications that are not in the modules folder. These are:
-- `observability`: This is a collection of applications that are used as a central observability stack. It is not a single application, but a collection of applications that are used to provide observability for the clusters. This is deployed in the `observability` folder. It runs on the redcliff cluster for high availability.
-- `rancher` since rancher is used to manage all clusters, it is not deployed in the modules folder. It is deployed in the `rancher` folder. It runs on the management cluster for isolation.

# Automated updates
Renovate bot is used to automatically find updates for applications. It will create PRs for each application that needs to be updated. The PRs will be created in the `modules` folder. The PRs will be created for each application on a module level. This means if an applications is hosted on multiple clusters, it will create a singular PR for the application across all clusters. As such it is important to ensure that the cluster modules should regularly be ran to ensure that the applications are updated.