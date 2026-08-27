data "proxmox_virtual_environment_vms" "templates" {
  node_name = "proxmox"
  tags      = ["template"]
}