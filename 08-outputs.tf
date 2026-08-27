output "proxmox_templates" {
  value = {
    for vm in data.proxmox_virtual_environment_vms.templates.vms :
    vm.name => {
      vm_id = vm.vm_id
      tags  = vm.tags
    }
  }
}