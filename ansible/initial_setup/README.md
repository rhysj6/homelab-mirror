# Initial linux setup
This Ansible playbook is designed to set up a few standard things on a new Linux server. It is intended to be run on a fresh installation of a Linux distribution, such as Ubuntu or Debian. The playbook will do the following:
- Create a new ansible user with sudo privileges and SSH key authentication. This user will be used to run Ansible playbooks on the server.
- Enable passwordless sudo for my user as that is a personal preference.
- Install and configure Grafana Alloy to collect logs and metrics and send them to my Prometheus and Loki instances.
- On hosts in the vm_servers group, install the QEMU guest agent to allow for better integration with Proxmox VE.