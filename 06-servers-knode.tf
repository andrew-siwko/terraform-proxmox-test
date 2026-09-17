locals {
  knode_vms = {
    "knode09" = { id = 209, clone_id = 9003, cores = 4, memory = 4000, disk = 50, pool = 10, ip = "192.168.50.171/24" }
  }
  gateway = "192.168.50.1"
}

resource "proxmox_virtual_environment_file" "cloud_config_knode" {
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
    EOF

    file_name = "vendor-data-agent-knode.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "knodes" {
  for_each  = local.knode_vms
  name      = "proxmox-${substr(each.key, 4, 2)}"
  node_name = "proxmox"
  vm_id     = each.value.id

  agent {
    enabled = true
    wait_for_ip {
      ipv4 = true
    }
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
    datastore_id = "m2"
    interface    = "scsi0"
    size         = each.value.disk
  }

  network_device { 
    bridge = "vmbr0" 
  }

  initialization {
    vendor_data_file_id = proxmox_virtual_environment_file.cloud_config_knode.id    
    
    ip_config {
      ipv4 { 
        address = each.value.ip
        gateway = local.gateway
      }
    }

    user_account {
      username = "asiwko"
      keys     = [trimspace(file(var.ssh_public_key_path))] 
    }
  }
}