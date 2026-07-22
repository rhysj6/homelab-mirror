# My Homelab

This repository contains the Infrastructure as Code for my homelab, built around Terraform, Terragrunt, and Ansible.

The focus is to automate day-to-day infrastructure operations while keeping everything reproducible, testable, and easy to evolve.

For full topology, networking, data flow, and service relationships, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Repository Layout

- `terraform/`: Reusable modules for cluster, applications, observability, and networking.
- `terragrunt/`: Environment orchestration for redcliff, test, and networking stacks.
- `ansible/`: Host and service configuration, including self-hosted runner automation.
- `tests/kubernetes/`: Go terratest integration suite for pre-production validation.

## Core Tooling

- Terraform + Terragrunt
- Ansible
- Talos + Kubernetes + Cilium
- GitHub Actions (self-hosted runner)
- Go + Terratest

## Environments And Config

- Primary environment: redcliff
- Validation environment: test (ephemeral)
- Network and version definitions are environment-scoped in:
  - [terragrunt/redcliff/env_inputs.hcl](terragrunt/redcliff/env_inputs.hcl)
  - [terragrunt/test/env_inputs.hcl](terragrunt/test/env_inputs.hcl)

## CI/CD And Validation

### Terragrunt Workflow

[.github/workflows/terragrunt.yaml](.github/workflows/terragrunt.yaml):

- Pull requests run plan.
- Pushes to main run apply.
- Path filters scope execution to changed stack sections.

### Kubernetes Test Workflow

[.github/workflows/test-kubernetes.yaml](.github/workflows/test-kubernetes.yaml):

- Manual workflow to run Kubernetes integration tests, spins up ephemeral test cluster, runs tests, and tears down the cluster.
- Generates test report output.

Local test targets are defined in [tests/Makefile](tests/Makefile).

### Public Mirror

[.github/workflows/public-mirror.yaml](.github/workflows/public-mirror.yaml) maintains the public mirror using `git filter-repo` string replacement before push.

## Hardware

- Clifton: Proxmox host (Ryzen 9, 64 GB RAM).
- Filton: Proxmox host (Intel i5, 64 GB RAM).
- Redcliff: 6 Kubernetes nodes (mix of VM and bare metal).
- Router: OPNSense on HP ProDesk 400 G3 Mini.
