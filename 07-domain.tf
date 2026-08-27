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


# Direct reference without time_sleep or complex locals
resource "linode_domain_record" "a_records" {
  for_each  = proxmox_virtual_environment_vm.vms
  domain_id = linode_domain.dns_zone.id
  name      = each.key
  record_type = "A"
  ttl_sec   = 5

  # Directly target the first reported IPv4 address safely
  target = [
    for ip in flatten(each.value.ipv4_addresses) :
    ip if ip != "127.0.0.1" && !startswith(ip, "169.254.")
  ][0]
}