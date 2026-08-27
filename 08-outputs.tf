output "proxmox_templates" {
  value = {
    for vm in data.proxmox_virtual_environment_vms.templates.vms :
    vm.name => {
      vm_id = vm.vm_id
      tags  = vm.tags
    }
  }
}

output "proxmox_vm1" {
  value = {
    id             = proxmox_virtual_environment_vm.test_vm1.id
    name           = proxmox_virtual_environment_vm.test_vm1.name
    node_name      = proxmox_virtual_environment_vm.test_vm1.node_name
    ipv4_addresses = proxmox_virtual_environment_vm.test_vm1.ipv4_addresses
  }
}

output "proxmox_vm2" {
  value = {
    id             = proxmox_virtual_environment_vm.test_vm2.id
    name           = proxmox_virtual_environment_vm.test_vm2.name
    node_name      = proxmox_virtual_environment_vm.test_vm2.node_name
    ipv4_addresses = proxmox_virtual_environment_vm.test_vm2.ipv4_addresses
  }
}