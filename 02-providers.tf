terraform {
  # I started out with this in an S3 bucket but keeping the state file in a shared folder
  # was easier for my purposes. 
  backend "local" {
    path = "/container_shared/tfstate/orproxmoxacle.tfstate"
  }
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }

    time = {
      source = "hashicorp/time"
    }
  
    # The linode provider will be used for the DNS management.
    linode = {
      source = "linode/linode"
    }

  }
}
provider "proxmox" {
  endpoint  = "https://proxmox.siwko.org:8006/"
  api_token = var.PROXMOX_API_KEY
  insecure  = true  # only if using the self-signed cert Proxmox ships with
}
provider "linode" {
  token = var.LINODE_API_KEY
}

