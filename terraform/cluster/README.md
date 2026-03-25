# Cluster
This folder has all the terraform modules for provisioning my kubernetes clusters. For test this includes the proxmox VMs that make up the cluster, other environments use a combination of proxmox and bare metal servers so the nodes aren't provisioned with terraform, but the rest of the software including the talos installation, CNI, ingress controllers and storage classes are all provisioned with terraform.

# Modules

## test_talos_nodes
Creates a 3 node cluster of talos VMs in proxmox, this is used so that I can spin up and down a test cluster in 10 minutes to test out new software and configurations before applying them to my production cluster. It downloads talos ISOs using the talos schematics to set the IP address of each node before it boots, this allows me to have a fully automated cluster provisioning process.

## talos_cluster
Installs talos on the nodes of the cluster (assuming that they're running in maintenance mode with the talos ISO), and then configures the cluster with my config and installs the Cilium CNI. This module is dynamic and can be used to setup any number of nodes.

## bootstrap_init and bootstrap_final
These modules install core software on the cluster such as traefik ingress controller, cert manager and longhorn. These are separate from the talos_cluster module as they need to be applied after the cluster is up and running so using terragrunt stacks allows me to easily control the order of operations and ensure that the cluster is fully up before trying to install these applications, rather than putting depends_on on every resource in these modules which would be a nightmare to maintain.

The reason there's two separate modules for the bootstrap is that some of the application CRDs need to be applied before the applications themselves, so the bootstrap_init module applies these CRDs and any other resources that don't rely on the CRDs, and then the bootstrap_final module applies the rest of the resources that rely on the CRDs. This allows me to avoid any issues with trying to apply resources that rely on CRDs that haven't been applied yet.