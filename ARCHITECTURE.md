# Network Architecture
## Physical Network & Subnets

```
┌──────────────────────────────────────────────────────────────────┐
│  OPNSense Router (HP ProDesk 400 G3)                             │
│                                                                  │
│  VLANs / Subnets:                                                │
│    10.10.10.0/24  – Redcliff cluster nodes (VLAN, all 6 nodes)   │
│    10.11.10.0/24  – LoadBalancer IP pool (BGP advertised)        │
│    10.48.0.0/12   – Proxmox SDN (EVPN, BGP advertised)           │
│      ├── 10.10.0.136/29  – MinIO VMs (to be decommissioned)      │
│      ├── 10.10.1.0/24    – Personal VMs                          │
│      └── ... future cross-site subnets                           │
└──────┬──────────────────────────────────┬────────────────────────┘
       │ BGP peering (ASN 65551)          │ BGP peering (SDN routes)
       │ Learns LB pool via Cilium        │ Learns 10.48.0.0/12 subnets
       │ (10.11.10.0/24)                  │ via Proxmox EVPN zone
       │                                  ▼
       │                     ┌────────────────────────────────────┐
       │                     │  Proxmox SDN (EVPN Zone)           │
       │                     │                                    │
       │                     │  10.48.0.0/12 prefix               │
       │                     │  – Cross-site L3 routing between   │
       │                     │    Clifton and Filton without      │
       │                     │    hairpinning via OPNSense        │
       │                     │  – Future: cross-site subnets for  │
       │                     │    multi-site workload placement   │
       │                     │                                    │
       │                     │     Not yet IaC'd — configured     │
       │                     │     manually in Proxmox            │
       ▼                     └────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────┐
│  Redcliff Kubernetes Cluster (Talos Linux)                      │
│                                                                 │
│  Nodes (10.10.10.11–16, OPNSense VLAN):                         │
│    .11, .12  – Control plane VMs (on Clifton + Filton)          │
│    .13       – Control plane bare metal                         │
│    .14, .15, .16  – Workers with Longhorn storage (bare metal)  │
│                                                                 │
│  Cilium CNI (kube-proxy replacement, BGP control plane)         │
│    – Peers with OPNSense (ASN 65555 local, 65551 peer)          │
│    – Advertises LoadBalancer IPs from pool 10.11.10.0/24        │
│    – KubeVIP holds the control plane VIP at 10.10.10.10         │
│                                                                 │
│  Key LoadBalancer IPs:                                          │
│    10.11.10.11  – Traefik (ingress, all HTTP/HTTPS traffic)     │
│    10.11.10.12  – Prometheus / monitoring                       │
│    10.11.10.53  – Technitium DNS                                │
└─────────────────────────────────────────────────────────────────┘
```

## How a Request Reaches a Service

```
External request (HTTPS)
        │
        ▼
OPNSense (port 443 forwarded to 10.11.10.11)
        │
        ▼
Traefik (LoadBalancer IP: 10.11.10.11)
        │  routes by hostname via Kubernetes Ingress rules
        ├──► authentik.homelab.example  ──► Authentik (SSO)
        ├──► grafana.homelab.example    ──► Grafana
        ├──► s3.homelab.example         ──► MinIO (via ExternalName svc)
        └──► *                        ──► other apps

Internal DNS (Technitium at 10.11.10.53)
        – External DNS operator auto-creates records for new services
        – Also handles local-only services not exposed externally
```

## How BGP LoadBalancer IPs Work

```
  New LoadBalancer Service created in Kubernetes
              │
              ▼
  Cilium assigns IP from pool (10.11.10.0/24)
              │
              ▼
  Cilium BGP control plane advertises the IP to OPNSense peer
              │
              ▼
  OPNSense installs route: 10.11.10.x ──► node running the pod
              │
              ▼
  Traffic arrives directly at the correct node (no extra hop)
```

## Storage & State

```
  Longhorn (distributed block storage across worker nodes)
    ├──► PersistentVolumes for stateful apps
    ├──► Loki log ingest storage
    └──► CNPG PostgreSQL data storage

  MinIO (3 VMs on Clifton + Filton + Offsite, 10.10.0.141–142 + Offsite IP)
    ├──► Terraform state backend  (s3.homelab.example)
    ├──► Loki log storage
    ├──► Longhorn backup target
    └──► CNPG PostgreSQL backups

  PostgreSQL (CNPG, LoadBalancer IP: 10.11.10.32)
    └──► Shared DB cluster used by Authentik, Infisical, NetBox etc.
```

## Physical Hosts & VM Layout

```
  Clifton (Ryzen 9, 64GB)          Filton (i5, 64GB)
  ├── Redcliff node-1 (VM, CP)     ├── Redcliff node-2 (VM, CP)
  ├── MinIO node 1                 ├── MinIO node 2
  ├── Automator LXC                └── other VMs and LXCs
  └── other VMs and LXCs

  Bare metal nodes (not on Proxmox):
  ├── Redcliff node-3 (CP)
  ├── Redcliff node-4 (worker + storage)
  ├── Redcliff node-5 (worker + storage)
  └── Redcliff node-6 (worker + storage)
```

# Github actions Architecture

All actions run on the self-hosted GitHub Actions runner `automator`, this is because the pipeline needs access to the private infrastructure in order to run the terragrunt commands. The `automator` server is setup in `ansible/automator.yml`.

## Public mirror of the repository
One of my goals since creating this homelab repository was to make it public so that others can learn from it and use it as a reference for their own homelabs. However, I didn't want to expose access to my private infrastructure by having the URLs and software versions publicly visible in the code. Initially, to solve this problem I used inifisical to store the domains as secrets and then referenced these secrets in the Terraform code, but this became messy. The solution I settled on was to have a public mirror of the repository that has the sensitive information removed.

This public mirror is automatically kept in sync with the private repository using a GitHub action that runs regularly and pushes any changes from the private repository to the public mirror, it uses `git filter-repo` to remove the sensitive information from the commit history so that it's not visible in the public mirror. This allows me to have a public repository that others can learn from, without exposing any sensitive information about my infrastructure.

## Terragrunt CI and CD pipeline
In order to automate the deployment of my infrastructure and applications, I have set up a CI/CD pipeline using GitHub Actions. When it runs on a pull request, it will run the applicable terragrunt stacks in plan mode based on the files changed.

When it runs on a push to main, it will run the applicable terragrunt stacks in apply mode based on the files changed. It has a concurrency group to prevent multiple runs from happening at the same time and also means that if I push multiple commits in quick succession, it will only run the pipeline for the latest commit, which is useful for when I'm merging multiple update pull requests at the same time.

The pipeline uses path filtering to only run the stacks affected by a given change:

- Changes to `terraform/applications/**` or `terragrunt/redcliff/applications/**` → runs the applications stack
- Changes to `terraform/cluster/**` or `terragrunt/redcliff/cluster/**` → runs the cluster stack
- Changes to `terraform/observability/**` or `terragrunt/redcliff/observability/**` → runs the observability stack
- Changes to root files (`root.hcl`, `env.hcl`, `providers.tf`, `versions.tf`) → runs all stacks, as these affect every module

# Observability Architecture
For monitoring and observability, I use a combination of Prometheus, Grafana and Loki. Prometheus is used for metrics collection, Grafana is used for visualisation and Loki is used for log aggregation. These are all deployed in Kubernetes and are exposed via LoadBalancer IPs or Ingress rules.

Metrics within the cluster are collected using the prometheus operator, which automatically discovers and scrapes metrics from Kubernetes components and applications and logs are collected using Grafana Alloy, which runs on the cluster and forwards all pod logs to Loki.

On individual servers, I use Grafana Alloy to collect logs and metrics and forward them to Loki and Prometheus respectively, this allows me to have a single location for all of my observability data, and also allows me to use the same Grafana instance to visualise both cluster and server metrics and logs.
