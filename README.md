# My Homelab
This repository contains the infrastructure as code (IaC) for my homelab, which is built primarily using Terraform and Ansible. The goal is to automate the deployment and management of my homelab environment, so that I can easily test, experiment, and learn new technologies whilst maintaining a consistent setup so that I can rely on it for self-hosted services. This is what I would define as my fifth homelab iteration, as I have gone through several iterations of my homelab setup over the years, each time learning from the previous one and improving my setup or implementing new technologies that have peaked my interest.

# Hardware
I have a small number of different devices that I use for my homelab.

## Clifton
This is my main virtualization host, which runs Proxmox VE. It is a custom-built server with a Ryzen 9 CPU and 64 GB of RAM, which provides plenty of resources for running multiple virtual machines and containers.

## Redcliff cluster
This is a cluster of three HP Elitedesk 800 G3 Mini PCs, which I use for my main Kubernetes cluster. Each node has a 4 core processor, 16 GB of RAM, and a 512 GB SSD.

## Filton
This is my friend's offsite (onsite for me) virtualization host, which runs VMware ESXi that I have a few VMs running on. I only use it for hosting a second MinIO instance.

## Router
This is my home router, which runs OPNSense. It is a HP ProDesk 400 G3 Mini PC with two gigabit Ethernet ports.

# Core Components or technologies
This section describes the core components of my homelab, which are used to provide the infrastructure and services that I rely on. The majority of these components are deployed and managed using Terraform.

## MinIO
MinIO is an self-hostable S3 alternative that I use for storing backups from my kubernetes and postgresql clusters as well as for terraform state storage.

## PostgreSQL
I use Cloud Native PostgreSQL (CNPG) to provision and manage PostgreSQL clusters in my Kubernetes cluster. It provides a simple way to deploy and manage PostgreSQL clusters, with support for high availability, backups, and scaling.

## Kubernetes
I use Kubernetes as the container orchestration platform for my homelab. It allows me to deploy and manage containers in a highly available and scalable way, with support for rolling updates, scaling, and self-healing.

## Authentik
Authentik is an open-source identity provider that I use for single sign-on (SSO) and access control in my homelab. It provides a simple way to ensure that all of my services are secured with a single set of credentials with MFA support, and it integrates with the vast majority of the services I use.

## Traefik
Traefik is a modern reverse proxy that I use to route traffic to my services I have it installed as a Kubernetes Ingress Controller, which allows me to easily manage the routing of traffic to my services.

## Ansible and Semaphore UI
Ansible is a configuration management tool that I use to automate the configuration and updating of my servers. I use Semaphore as a web-based UI for Ansible, which allows me to easily manage and run Ansible playbooks from a web interface.

## Rancher
Rancher is a container management platform that I use to manage my Kubernetes clusters. It provides an easy-to-use web interface for looking at the state of my clusters, I also use it to manage the lifecycle of my clusters, including provisioning and upgrading.