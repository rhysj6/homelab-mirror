locals {
    vms = {
        test-node-1 = {
            vmid       = 3001
            ip_address = "10.10.20.11"
            storage_datastore = "BX-2TB-1"
        }
        test-node-2 = {
            vmid       = 3002
            ip_address = "10.10.20.12"
            storage_datastore = "MX-2TB-1"
        }
        test-node-3 = {
            vmid       = 3003
            ip_address = "10.10.20.13"
            storage_datastore = "MX-2TB-2"
        }
    }
}