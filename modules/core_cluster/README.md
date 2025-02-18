# What is this module?
This contains all cluster infrastructure that must be deployed to each new cluster

## Longhorn setup
Before installing make sure to do the following per node to ensure longhorn works

### Disable multipathd
``sudo systemctl disable multipathd``
``sudo systemctl stop multipathd``

### Ensure dependencies installed
Make sure to prepare nodes https://longhorn.io/docs/1.8.0/v2-data-engine/quick-start/#prerequisites

### Ensure kernal modules are loaded
Run ``nano /etc/modules-load.d/longhorn_deps.conf``

Then copy in this:
```
nvme-tcp
vfio_pci
uio_pci_generic
dm_crypt
iscsi_tcp
```