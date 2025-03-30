# What is this module?
This module contains any ingresses and other config that can forward traffic through the cluster.

# Why do you need this?
I only have one public IP address so I can only port forward to one IP, as such I choose to use my highly available redcliff cluster to ensure that the traffic gets where it needs to go. In some cases it is to other clusters so I don't terminate the SSL here.