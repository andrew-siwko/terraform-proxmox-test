data "proxmox_virtual_environment_vms" "templates" {
  node_name = "pve"
  tags      = ["template"]
}