resource "proxmox_virtual_environment_vm" "test_vm" {
  name      = "proxmox-01"
  node_name = "proxmox"      # your node's name
  vm_id     = 200

  clone {
    vm_id = 9001              # your cloud-init template's VM ID
    full  = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      username = "asiwko"
      keys     = [file(var.ssh_public_key_path)]
      
    }
  }
}