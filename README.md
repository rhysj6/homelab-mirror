# My Homelab
This repository contains the infrastructure as code (IaC) for my homelab, which is built primarily using Terraform and Ansible. The primary goal is to automate my homelab environment, so that I can easily test, experiment, and learn new technologies whilst keeping it all up to date. 

This is what I would define as my fifth homelab iteration, as I have gone through several iterations of my homelab setup over the years, each time learning from the previous one and improving my setup or implementing new technologies that have peaked my interest.

# Hardware
I have a small number of different devices that I use for my homelab.

- **Clifton**: This is my main virtualization host, which runs Proxmox VE. It is a custom-built server with a Ryzen 9 CPU and 64 GB of RAM, which provides plenty of resources for running multiple virtual machines and containers.

- **Redcliff cluster**: This is a cluster of three HP Elitedesk 800 G3 Mini PCs, which I use for my main Kubernetes cluster. Each node has a 4 core processor, 16 GB of RAM, and a 512 GB SSD.

- **Filton**: This is my friend's offsite (onsite for me) virtualization host, which runs VMware ESXi that I have a few VMs running on. I only use it for hosting a second MinIO instance.

- **Router**: This is my home router, which runs OPNSense. It is a HP ProDesk 400 G3 Mini PC with two gigabit Ethernet ports.

# Core Components or technologies
This section describes the core components of my homelab, which are used to provide the infrastructure and services that I rely on. The majority of these components are deployed and managed using Terraform.

- **MinIO**: Self-hosted S3 alternative for backups, mass application storage, and Terraform state storage.
- **Cloud Native PostgreSQL**: Managed PostgreSQL clusters in Kubernetes, providing high availability and backups.
- **Kubernetes**: Container orchestration platform for deploying and managing containers.
- **Authentik**: Identity provider for single sign-on (SSO) and access control.
- **Traefik**: Reverse proxy and Kubernetes Ingress Controller for routing traffic to services.
- **Ansible**: Configuration management and automation tool, used for automating the configuration and updating of servers.
- **Semaphore UI**: A web-based UI for managing Ansible playbooks, making it easier to run and schedule playbooks.
- **Rancher**: Container management platform for managing Kubernetes clusters, providing an easy-to-use web interface for looking at the state of my clusters and managing the lifecycle of my clusters.
