locals {
  kcontrol_vms = {
    "kcontrol02" = { id = 213, clone_id = 9013, node = "proxmox2",cores = 2, memory = 2500, disk = 50, pool = 10, ip = "192.168.50.156/24" }
    "kcontrol03" = { id = 214, clone_id = 9003, node = "proxmox", cores = 4, memory = 4000, disk = 50, pool = 10, ip = "192.168.50.157/24" }
  }

  vendor_data_by_node = {
    "proxmox2" = proxmox_virtual_environment_file.cloud_config_kcontrol.id
    "proxmox"  = proxmox_virtual_environment_file.cloud_config_knode.id
  }

}

resource "proxmox_virtual_environment_file" "cloud_config_kcontrol" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "proxmox2"

  source_raw {
    data = <<-EOF
      #cloud-config
      packages:
        - qemu-guest-agent
      runcmd:
        - systemctl enable --now qemu-guest-agent
    EOF

    file_name = "vendor-data-agent-kcontrol.yaml"
  }
}


resource "proxmox_virtual_environment_vm" "kcontrol" {
  for_each  = local.kcontrol_vms
  name      = "kcontrol${substr(each.key, 8, 2)}"
  node_name = each.value.node
  vm_id     = each.value.id

  bios = "ovmf"

  efi_disk {
    datastore_id = "local-lvm"
  }

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
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = each.value.disk
  }

  network_device { 
    bridge = "vmbr0" 
  }

  initialization {
    vendor_data_file_id = local.vendor_data_by_node[each.value.node]    
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