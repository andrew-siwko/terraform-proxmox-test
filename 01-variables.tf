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

# --- Authentication Variables ---
variable "tenancy_ocid" {
  description = "The OCID of your OCI tenancy"
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user calling the API"
  type        = string
}


variable "private_key_path" {
  description = "The path to your OCI API private key"
  type        = string
}

variable "oci_region" {
  description = "OCI region - my home region in this case"
  type        = string
  default     = "us-ashburn-1"
}

variable "subnet_ocid" {
  description = "The OCID of the subnet where the VM will reside"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key for instance access"
  type        = string
}