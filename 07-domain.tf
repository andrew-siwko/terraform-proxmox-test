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

resource "time_sleep" "wait_for_dhcp" {
  depends_on      = [proxmox_virtual_environment_vm.vms]
  create_duration = "45s"
}

resource "linode_domain_record" "a_records" {
  for_each    = proxmox_virtual_environment_vm.vms
  domain_id   = linode_domain.dns_zone.id
  name        = each.key
  record_type = "A"
  ttl_sec     = 5

  # Safely extracts the first non-loopback, non-link-local IPv4 address
  target = coalesce(
    one([
      for ip in flatten(each.value.ipv4_addresses) :
      ip if ip != "127.0.0.1" && !startswith(ip, "169.254.")
    ]),
    "127.0.0.1"
  )
  depends_on = [time_sleep.wait_for_dhcp]
}