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

# Records for the public IP addresses.
resource "linode_domain_record" "prox01_a_record" {
  domain_id   = linode_domain.dns_zone.id
  name        = "prox01"
  record_type = "A"
  ttl_sec     = 5
  target = [
    for ip in flatten(proxmox_virtual_environment_vm.test_vm1.ipv4_addresses) :
      ip if ip != "127.0.0.1" && !startswith(ip, "169.254.")
    ][0]

  depends_on = [time_sleep.wait_for_network]
}

resource "linode_domain_record" "prox02_a_record" {
  domain_id   = linode_domain.dns_zone.id
  name        = "prox02"
  record_type = "A"
  ttl_sec     = 5
  target = [
    for ip in flatten(proxmox_virtual_environment_vm.test_vm2.ipv4_addresses) :
      ip if ip != "127.0.0.1" && !startswith(ip, "169.254.")
    ][0]

  depends_on = [time_sleep.wait_for_network]
}

