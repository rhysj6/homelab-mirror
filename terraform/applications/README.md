# Applications
This directory contains Terraform code for applications that run in my homelab on Kubernetes. These are applications that I run in Kubernetes, but aren't necessarily related to the cluster itself. The reason for having a separate folder for applications is that I want to be able to deploy these applications across multiple clusters and environments without having to duplicate the code. Each application has its own folder, and within that folder is a terragrunt.hcl file that defines the inputs for the application and its dependencies.

# Modules

## gateway
This isn't a real application, but a collection of ingresses and services to allow for reverse proxying to non-kubernetes services.

## authentik and authentik_config
These modules are used to deploy and configure my authentik instance, which is the identity provider for my homelab. I use authentik for single sign-on (SSO) and access control for all of my applications, so it's a critical part of my homelab infrastructure. The authentik module deploys the authentik instance itself, and the authentik_config module is used to configure the instance with my specific settings. This separation prevents any race conditions during deployment, as the authentik instance needs to be up and running before I can apply the configuration to it. This also allows me to easily deploy the authentik instance without applying the configuration, which is useful for testing and debugging.

## cnpg
Cloud native PostgreSQL (cnpg) is a PostgreSQL operator for Kubernetes, I use it to run my PostgreSQL cluster that most of my applications use for their databases. I use cnpg because it provides high availability and automated backups for my PostgreSQL cluster, which is critical for ensuring that my applications have reliable access to their data.

## postgresql
This module deploys the postgres cluster using the cnpg operator, it also dynamically creates the databases and users for my applications and stores the credentials for these in Infisical for later use in applications.

## infisical
Manages the infisical deployment in my cluster. This is used to store secrets for the vast majority of the IaC in this repo. There is a bit of a chicken and egg problem with infisical as I use it to store secrets for the IaC for the clusters, I have minimised the use of infisical in the cluster provisioning code to try and avoid this as much as possible, but for applications it's a lot easier to use infisical as I don't have the same constraints.

## technitium_dns and external_dns
Technitium is the main DNS server for my homelab, it runs in Kubernetes and manages local DNS and adblocking. I use the technitium_dns module to deploy technitium, and then I use the external_dns module to deploy external DNS which is used to automatically create DNS records in technitium for my applications. This allows me to have some local only applications that aren't exposed to the internet.

## jenkins
This module deploys Jenkins in my cluster, I occasionally use Jenkins, but have found that Github Actions and Semaphore UI are usually sufficient for my needs, so Jenkins is mostly just there for testing and learning purposes. I have built the IaC for Jenkins in a way that allows me to easily tear it down and redeploy it, as I don't need it to be up all the time.
