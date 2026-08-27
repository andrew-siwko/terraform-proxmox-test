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

data "proxmox_virtual_environment_vm" "vms_data" {
  for_each   = proxmox_virtual_environment_vm.vms
  node_name  = each.value.node_name
  vm_id      = each.value.vm_id
  depends_on = [time_sleep.wait_for_dhcp]
}
resource "linode_domain_record" "a_records" {
  for_each    = data.proxmox_virtual_environment_vm.vms_data
  domain_id   = linode_domain.dns_zone.id
  name        = each.key
  record_type = "A"
  ttl_sec     = 5

  # Gracefully retrieves the first non-loopback, non-APIPA IP address
  target = coalesce(
    one([
      for ip in flatten(each.value.ipv4_addresses) :
      ip if ip != "127.0.0.1" && !startswith(ip, "169.254.")
    ]),
    "127.0.0.1" # Fallback IP if state is missing during initial plan
  )

  depends_on = [time_sleep.wait_for_network]
}