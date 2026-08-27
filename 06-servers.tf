locals {
  vms = {
    "prox01" = { id = 201, clone_id = 9001, cores = 3, memory = 2048, disk = 30 }
    "prox02" = { id = 202, clone_id = 9002, cores = 3, memory = 1024, disk = 10 }
  }
}

# 1. Provision VMs using for_each to avoid code duplication
resource "proxmox_virtual_environment_vm" "vms" {
  for_each  = local.vms
  name      = "proxmox-${substr(each.key, 4, 2)}"
  node_name = "proxmox"
  vm_id     = each.value.id

agent {
    enabled = true
    wait    = true      # Blocks resource creation until Guest Agent responds
    timeout = "3m"      # Maximum time to wait before failing (e.g. 3 minutes)
  }
  clone {
    vm_id = each.value.clone_id
    full  = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory { dedicated = each.value.memory }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = each.value.disk
  }

  network_device { bridge = "vmbr0" }

  initialization {
    ip_config {
      ipv4 { address = "dhcp" }
    }
    user_account {
      username = "asiwko"
      keys     = [file(var.ssh_public_key_path)]
    }
  }
}


