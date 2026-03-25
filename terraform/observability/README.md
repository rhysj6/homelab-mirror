# Observability
This directory contains Terraform code for setting up observability in my homelab. This includes Grafana, Loki and Alloy for monitoring and logging. Prometheus is also used for monitoring, but that is deployed as part of the cluster modules due to CRD race conditions. The reason for having a separate folder for observability is that I only need one environment of these tools, and they are used across all of my clusters and applications, so it makes sense to have them in a separate folder rather than being duplicated across each environment.

# Modules

## grafana
This module sets up Grafana in my homelab, it includes the Grafana deployment, as well as some dashboards and data sources. The dashboards are mostly imported from the Grafana dashboard repository. The data sources include Loki for logging, and Prometheus for monitoring. The Grafana instance is also configured to use my Authentik instance for authentication, so that I can use SSO to access Grafana.

## loki
This module sets up Loki in my homelab, it includes the Loki deployment, as well as the necessary configuration for it to work with Grafana. Loki is used for logging in my homelab, and is configured to receive logs from my Kubernetes clusters and other applications. The logs are then visualized in Grafana using the Loki data source. Data is stored in a MinIO bucket, but I'm looking to replace this soon as it's end of life.

## alloy
This module sets up Grafana Alloy in my homelab, I use this to aggregate logs from my Kubernetes clusters and other applications, and then forward them to Loki for storage. Alloy is a really powerful tool for aggregating observability data, I also install it on my individual servers to collect logs from non-kubernetes applications and forward them to Loki, this allows me to have a single location for all of my logs.