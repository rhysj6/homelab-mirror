# What is this?
This isn't a real application, but a collection of ingresses and services to allow for reverse proxying to non-kubernetes services. It should be deployed to several clusters to allow for easy disaster recovery and failover.

# Why do you need this?
I only have one public IP address so I can only port forward to one IP, as such I choose to use my highly available redcliff cluster to ensure that the traffic gets where it needs to go. In some cases it is to other clusters so I don't terminate the SSL here.