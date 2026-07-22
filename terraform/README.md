# Terraform
This folder contains the terraform code for my homelab, these are used in conjunction with terragrunt to make reusable units of infrastructure that can be easily deployed across multiple environments.

There are several categories of terraform code in this repository:
- **cluster**: for provisioning my kubernetes clusters, this includes the base level software running on the cluster such as CNI, ingress controllers and storage classes.
- **applications**: for deploying any applications to my clusters, this includes things like my monitoring stack, and any applications that I run in kubernetes.
- **observability**: for provisioning any observability tools that I use in my homelab, such as Grafana and Prometheus. This is separate from applications as I intend to only need one environment of these tools.
- **modules**: a few reusable terraform modules that get used directly in my terraform code, such as a module for setting up an application in authentik.

# Structure
Each terraform module has a terragrunt.hcl file that defines the inputs for the module and it's dependencies, these are then called from each enviroment's terragrunt stacks (based on the parent folder structure). For example, the `cluster` modules are called from the `<environment>/cluster` folder. This allows me to have a clear separation of concerns and makes it easy to deploy the same infrastructure across multiple environments. When it comes to environment specific inputs, these are defined in the `env_inputs.hcl` file in each environment folder, and then passed down to the modules through the terragrunt.hcl files.