output "knode_vms" {
  value = {
    for vm in proxmox_virtual_environment_vm.knodes :
    vm.name => {
      id = vm.id
      node_name  = vm.node_name
      ipv4_addresses = vm.ipv4_addresses
    }
  }
}

output "kcontrol_vms" {
  value = {
    for vm in proxmox_virtual_environment_vm.kcontrol :
    vm.name => {
      id = vm.id
      node_name  = vm.node_name
      ipv4_addresses = vm.ipv4_addresses
    }
  }
}
