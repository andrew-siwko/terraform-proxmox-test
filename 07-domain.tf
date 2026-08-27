# ONLY for the siwko.org domain on Linode
# use this once to get the zone into the state file
# terraform import linode_domain.domain_name 3417841

# This will update the dns records in my siwko.org domain for the new instances.
resource "linode_domain" "dns_zone" {
  type        = "master"
  domain      = var.domain_name
  soa_email   = var.domain_soa_email
  refresh_sec = 30
  retry_sec   = 30
  ttl_sec     = 30

  lifecycle {
    prevent_destroy = true
  }
}

resource "time_sleep" "wait_for_network" {
  depends_on      = [proxmox_virtual_environment_vm.vms]
  create_duration = "30s"
}
resource "time_sleep" "wait_for_dhcp" {
  depends_on      = [proxmox_virtual_environment_vm.vms]
  create_duration = "45s"
}

data "proxmox_virtual_environment_vms" "vms_data" {
  node_name  = "proxmox"
  depends_on = [time_sleep.wait_for_dhcp]
}

output "proxmox_vms_all" {
  description = "Full Proxmox VM objects retrieved after network configuration"
  value       = data.proxmox_virtual_environment_vms.vms_data
}

# Local mapping to extract IP for each VM by matching VM ID
locals {
  vm_ip_map = {
    for key, vm_cfg in local.vms : key => coalesce(
      one([
        for vm in data.proxmox_virtual_environment_vms.vms_data.vms :
        flatten(vm.ipv4_addresses) if vm.vm_id == vm_cfg.id
      ]),
      []
    )
  }
}

resource "linode_domain_record" "a_records" {
  for_each    = local.vms
  domain_id   = linode_domain.dns_zone.id
  name        = each.key
  record_type = "A"
  ttl_sec     = 5

  target = coalesce(
    one([
      for ip in local.vm_ip_map[each.key] :
      ip if ip != "127.0.0.1" && !startswith(ip, "169.254.")
    ]),
    "127.0.0.1"
  )
}