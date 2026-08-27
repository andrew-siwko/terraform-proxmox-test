output "proxmox_templates" {
  value = {
    for vm in data.proxmox_virtual_environment_vms.templates.vms :
    vm.name => {
      vm_id = vm.vm_id
      tags  = vm.tags
    }
  }
}

output "proxmox_vm" {
  value = {
    id             = proxmox_virtual_environment_vm.test_vm.id
    name           = proxmox_virtual_environment_vm.test_vm.name
    node_name      = proxmox_virtual_environment_vm.test_vm.node_name
    ipv4_addresses = proxmox_virtual_environment_vm.test_vm.ipv4_addresses
    cores          = proxmox_virtual_environment_vm.test_vm.cpu[0].cores
    memory         = proxmox_virtual_environment_vm.test_vm.memory[0].dedicated
  }
}