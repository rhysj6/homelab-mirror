# What is this
This is my centralised observability stack containing: grafana, loki, prometheus, and alloy. It provides comprehensive monitoring and logging capabilities for applications and infrastructure. The stack is designed to be modular and reusable, allowing for easy deployment across multiple environments and clusters.

# How is this module structured
This module is structured in a simple way because the long term storage is store in minio rather than the kubernetes cluster it is deploy to, this means that we can easily move the observability stack between clusters without worrying about the long term storage. The module is structured as follows:
```
alloy_config/ # This contains all configurations for the alloy application deployed to the cluster, this is written into a config map
    pod_config.alloy 
grafana_configs/
    sources/ # This contains all the grafana sources, this is written into a config map and uses templating to manage secrets
        loki.yaml
    dashboards/ # This contains all the grafana dashboards, this is written into a config map, these can be downloaded from the grafana dashboard site
        linux-nodes.json
templates/ # Contains all of the helm values used for the helm charts
```