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


resource "linode_domain_record" "knode_a_records_knode" {
  for_each    = local.knode_vms
  domain_id   = linode_domain.dns_zone.id
  name        = each.key
  record_type = "A"
  ttl_sec     = 5

  # Safely extracts the LAN IPv4 address, ignoring loopback/link-local/pod-network interfaces
  target = coalesce(
    one([
      for ip in flatten(proxmox_virtual_environment_vm.knodes[each.key].ipv4_addresses) :
      ip if startswith(ip, "192.168.50.")
    ]),
    "127.0.0.1"
  )
  # depends_on = [time_sleep.wait_for_dhcp]
}

resource "linode_domain_record" "kcontrol_a_records_kcontrol" {
  for_each    = local.kcontrol_vms
  domain_id   = linode_domain.dns_zone.id
  name        = each.key
  record_type = "A"
  ttl_sec     = 5

  # Safely extracts the LAN IPv4 address, ignoring loopback/link-local/pod-network interfaces
  target = coalesce(
    one([
      for ip in flatten(proxmox_virtual_environment_vm.kcontrol[each.key].ipv4_addresses) :
      # exclude the VIP address on all kcontrols
      ip if startswith(ip, "192.168.50.") && ip != "192.168.50.155"
    ]),
    "127.0.0.1"
  )
  # depends_on = [time_sleep.wait_for_dhcp]
}