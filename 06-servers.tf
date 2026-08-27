resource "proxmox_virtual_environment_vm" "test_vm1" {
  name      = "proxmox-01"
  node_name = "proxmox"
  vm_id     = 201

  agent {
    enabled = true
  }

  clone {
    vm_id = 9001
    full  = true
  }

  cpu {
    cores = 3
    type  = "host"
  }

  memory {
    dedicated = 2048
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
      keys     = [trimspace(file(var.ssh_public_key_path))]
    }
  }
}

resource "proxmox_virtual_environment_vm" "test_vm2" {
  name      = "proxmox-02"
  node_name = "proxmox"
  vm_id     = 202

  agent {
    enabled = true
  }

  clone {
    vm_id = 9002
    full  = true
  }

  cpu {
    cores = 3
    type  = "host"
  }

  memory {
    dedicated = 1024
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 10
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
      keys     = [trimspace(file(var.ssh_public_key_path))]
    }
  }
}

resource "time_sleep" "wait_for_network" {
  depends_on      = [proxmox_virtual_environment_vm.test_vm1,proxmox_virtual_environment_vm.test_vm2]
  create_duration = "30s"
}