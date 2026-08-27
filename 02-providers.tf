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
  ssh {
    enabled     = true
    username    = "root"
    private_key = file("/container_shared/ansible/jenkins_rsa")
    
    # Ensures it uses the hostname/IP from the endpoint
    node {
      name    = "proxmox"
      address = "192.168.50.183" # or "proxmox.siwko.org"
    }
  }
}

provider "linode" {
  token = var.LINODE_API_KEY
}

