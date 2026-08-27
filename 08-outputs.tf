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
  value=proxmox_virtual_environment_vm.test_vm.*
  sensitive = true
}