output "proxmox_templates" {
  value = {
    for vm in data.proxmox_virtual_environment_vms.templates.vms :
    vm.name => {
      vm_id = vm.vm_id
      tags  = vm.tags
    }
  }
}

output "proxmox_vms" {
  value = {
    for vm in data.proxmox_virtual_environment_vm.vms_data :
    vm.name => {
      id = vm.id
      node_name  = vm.node_name
      ipv4_addresses = vm.ipv4_addresses
    }
  }
}
