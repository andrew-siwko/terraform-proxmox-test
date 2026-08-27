variable "LINODE_API_KEY" {
  description = "The key to the Linode API"
  type        = string
  sensitive   = true
}

variable "PROXMOX_API_KEY" {
  description = "The key to the Proxmox API"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "The domain to create instance records in."
  type    = string
  default = "siwko.org"
}

variable "domain_soa_email" {
  description = "The domain manager e-mail address."
  type    = string
  default = "asiwko@siwko.org"
}


variable "ssh_public_key_path" {
  description = "Path to the SSH public key for instance access"
  type        = string
}