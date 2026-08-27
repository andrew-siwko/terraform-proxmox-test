resource "proxmox_virtual_environment_vm" "test_vm" {
  name      = "proxmox-01"
  node_name = "proxmox"
  vm_id     = 200

  agent {
    enabled = true
  }

  clone {
    vm_id = 9001
    full  = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 30
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

resource "time_sleep" "wait_for_network" {
  depends_on      = [proxmox_virtual_environment_vm.test_vm]
  create_duration = "30s"
}