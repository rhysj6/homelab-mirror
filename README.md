# My Homelab
This repository contains the infrastructure as code (IaC) for my homelab, which is built primarily using Terraform and Ansible. The primary goal is to automate any day-to-day tasks to do with managing my homelab such as updating servers, services and applications. I want to ensure that my homelab is resilient and can recover from failures, while also being easy to manage and maintain.

I have been running a homelab for several years now, and it has evolved significantly over time. I started with a single Raspberry Pi running open media vault. This is what I would define as my sixth homelab iteration, as I have gone through several iterations of my homelab setup over the years, each time learning from the previous one and improving my setup or implementing new technologies that have peaked my interest.

# Hardware
I have a small number of different devices that I use for my homelab.

- **Clifton**: This is my main virtualization host, which runs Proxmox VE. It is a custom-built server with a Ryzen 9 CPU and 64 GB of RAM, which provides plenty of resources for running multiple virtual machines and containers.

- **Redcliff cluster**: This is a cluster of 6 nodes (4 bare metal, 2 virtual), which I use for my main Kubernetes cluster. Each node has a 4 core processor, 16 GB of RAM, and a 512 GB SSD.

- **Filton**: This is a secondary virtualization host, which also runs Proxmox VE. It is a custom-built server with an Intel i5 CPU and 64 GB of RAM, which I use for running additional virtual machines and containers that don't require as many resources as Clifton provides.

- **Router**: This is my home router, which runs OPNSense. It is a HP ProDesk 400 G3 Mini PC with two gigabit Ethernet ports.

# Core Components or technologies
This section describes the core components of my homelab, which are used to provide the infrastructure and services that I rely on. The majority of these components are deployed and managed using Terraform.

- **Ansible**: Configuration management and automation tool, used for automating the configuration and updating of my non-kubernetes infrastructure.
- **Terraform + Terragrunt**: Infrastructure as code tool, used for provisioning and managing my infrastructure across multiple providers (e.g., Proxmox, OPNSense, Cloudflare).
- **Kubernetes**: Container orchestration platform for deploying and managing containers. A lot of my homelab and interests revolve around Kubernetes.
- **Authentik**: Identity provider for single sign-on (SSO) and access control.
- **Traefik**: Reverse proxy and Kubernetes Ingress Controller for routing traffic to services.
- **Infisical**: Secrets management tool for securely storing and managing sensitive information. Used extensively in my IaC to avoid hardcoding secrets in Terraform and Ansible.
- **Cloud Native PostgreSQL**: Managed PostgreSQL clusters in Kubernetes, providing high availability and backups.
- **MinIO**: Self-hosted S3 alternative for backups, mass application storage, and Terraform state storage. I'm looking to replace this soon as it's end of life.
- **Semaphore UI**: A web-based UI for running and scheduling Ansible playbooks.
- **Renovate**: Automated dependency management tool that creates pull requests for updates to applications and modules, ensuring that my homelab is always up-to-date with the latest versions of software.
- **Github Actions**: CI/CD platform for automating terraform runs, allows me to update software from the comfort of my phone and ensures that my infrastructure is always up-to-date.
