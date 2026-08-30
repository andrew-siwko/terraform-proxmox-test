locals {
  vms = {
    "prox01" = { id = 201, clone_id = 9002, cores = 1, memory = 800, disk = 10, pool=10 }
    "prox02" = { id = 202, clone_id = 9002, cores = 1, memory = 800, disk = 10, pool=10 }
    "prox03" = { id = 203, clone_id = 9002, cores = 1, memory = 800, disk = 10, pool=10 }
    "prox04" = { id = 204, clone_id = 9002, cores = 1, memory = 800, disk = 10, pool=10 }
    "prox05" = { id = 205, clone_id = 9002, cores = 1, memory = 800, disk = 10, pool=10 }
    "prox06" = { id = 206, clone_id = 9002, cores = 1, memory = 800, disk = 10, pool=10 }
    "prox07" = { id = 207, clone_id = 9002, cores = 1, memory = 800, disk = 10, pool=10 }
    "prox08" = { id = 208, clone_id = 9002, cores = 1, memory = 800, disk = 10, pool=10 }
  }
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "proxmox"

  source_raw {
    data = <<-EOF
      #cloud-config
      packages:
        - qemu-guest-agent
      runcmd:
        - systemctl enable --now qemu-guest-agent
      mounts:
        - [ /dev/sdb, /pool1, ext4, "defaults", "0", "2" ]
    EOF

    file_name = "vendor-data-agent.yaml"
  }
}
resource "proxmox_virtual_environment_vm" "vms" {
  for_each  = local.vms
  name      = "proxmox-${substr(each.key, 4, 2)}"
  node_name = "proxmox"
  vm_id     = each.value.id

  agent {
    enabled = true
  }

  clone {
    vm_id = each.value.clone_id
    full  = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory { 
    dedicated = each.value.memory 
    }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = each.value.disk
  }
  disk {
    datastore_id = "pool1"
    interface    = "scsi1"
    size         = each.value.pool
  }

  network_device { 
    bridge = "vmbr0" 
    }

  initialization {
    vendor_data_file_id = proxmox_virtual_environment_file.cloud_config.id    
    ip_config {
      ipv4 { address = "dhcp" }
    }
    user_account {
      username = "asiwko"
      keys     = [trimspace(file(var.ssh_public_key_path))] 
    }
  }
}