# Andrew's Multicloud Terraform Experiment
## Overview
This experiment uses Terraform to create a single virtual machine on [Oracle's cloud](https://www.oracle.com/cloud/sign-in.html).  It is part of a series of experiments begun in early 2026.  I have structured the Terraform files with sequence numbers to show the logical flow of resource creation.  Roughly the sequence is:
* 00-create-resources.bash
  * This file contains shell commands and notes used to manipulate the cloud environment from the CLI.  My approach has been to make things work and then Terraform them.  Thus you may see commands to discover the instance types which I used to hard code server creation.  These were later replaced with lookups inside terraform.  the commands and notes may still be useful.
* 01-variables.auto.tfvars, 01-variables.tf
  * The two variable files contain parameters factored out of the main code and their definitions.  As the configuration code matured and I added more cloud providers, it became clear that certain parameters could be pulled up for ease of use.
* 02-providers.tf
  * This file contains the top level terraform{} block which contains required providers, by necessity, the backend definition and connects providers to required variables.  I would have liked to split the backend into a separate file but there may only be one terraform{} block and the rest of the world uses providers.  In these projects I have stored the tfstate file on the cloud provider rather than defining local storage.  I found this proceess to be difficult and educational.
* 03-data.tf
  * This file contains data statements to query the cloud provider for images and instance types.  The results are stored in local variables and used to create the VM instance.  This file arose from the early struggles I had with finding available resources with compatible type, image and location.
* 04-network.tf
  * This file specifies network elements.  In a basic, single VM case, it is not generally needed.  As soon as you want to control traffic with a firewall or security group, the network definition is required to attach the rules.
* 05-security-group.tf, 04-firewall.tf, 04-security-list.tf
  * This file defines how network traffic flows in and out of the network to your instance.
* 06-ec2.tf, 05-machine.tf, 05-droplet.tf, 05-servers.tf
  * This file contains the virtual machine definition and mapping to other resources.
* 07-domain.tf
  * This small file contains the DNS Zone resource for a Linode zone and an A record for the IP address of the virtual machine.  The zone record is imported from the existing Linode zone and is marked as "prevent_destroy" to avoind domain deletion.
* 08-outputs.tf
  * This file contains outputs from Terraform state at the end of the process.  During development, I leaned on this heavily to discover internal states and key names.  Once finished, I leave the public IP of the instance in the output for validation.


Except for Linode, with whom I have an existing paid relationship, all other instances were provisioned using a free trial.
Once Terraform provisioning is complete, I use Ansible to configure and install Tomcat, set an apache proxy and install a sample application.  [More on that later...](https://github.com/andrew-siwko/ansible-multi-cloud-tomcat-hello)

## Multicloud
I tried to build the same basic structures in each of the cloud environments.  Each one starts with providers (and a backend), lays out the network and security, creates the VM and then registers the public IP in my DNS.  There is some variability which has been interesting to study.  The Terraform state file is stored on each provider.
* Step 1 - [Amazon AWS](https://github.com/andrew-siwko/terraform-aws-test)
* Step 2 - [Microsoft Azure](https://github.com/andrew-siwko/terraform-azure-test)
* Step 3 - [Google GCP](https://github.com/andrew-siwko/terraform-gcp-test)
* Step 4 - [Linode](https://github.com/andrew-siwko/terraform-linode-test)
* Step 5 - [IBM Cloud](https://github.com/andrew-siwko/terraform-ibm-test)
* Step 6 - [Oracle OCI](https://github.com/andrew-siwko/terraform-oracle-test) (you are here)
* Step 7 - [Digital Ocean](https://github.com/andrew-siwko/terraform-digital-ocean-test)

## Build Environment
I stood up my own Jenkins server and built a freestyle job to support the Terraform infrastructure builds.  Jenkins polls this GitHubrepo and when changes are detected, starts a job whic performs the following steps:
* terraform init
* terraform state list | grep -q "linode_domain.dns_zone"
  * _If the zone is not found, import it_
  * Terraform import linode_domain.dns_zone 3417841
* terraform plan
* terraform apply -auto-approve
* terraform output (This is piped to mail so I get an e-mail with the outputs.)

The Jenkins job contains environment variables with authentication information for the cloud environment and [Linode](https://www.linode.com/) my DNS registrar.
The zone resource has to be in terraform to attach the A record for the newly created VM.  Note that the zone resource is marked as "prevent_destroy" in order to stop Terraform from destroying the entire domain zone.


## Observations
* This was my sixth cloud provisioning project.  I was happy with the other 5 but asked Google Gemini whether there were other providers.  It suggested Oracle and Digital Ocean
* It took me one day to get my VM provisioned.  One painful day.  I spent lots of time in the oci console which is super-helpful even if difficult to learn.  I really should learn jq also.  The biggest difficulty was trying to get a subnet to attach to the instance.  Without a dns_label on the subnet and vcn, Terraform would fail with vague work request errors.  Fortunately I had a network from 6 years ago that worked with the instance.  I was able to build the network without the instance then woth the diffs to closure.  That alone took 6 hours.
* When I figured out how to find an Oracle 9.7 image for the shape in my compartment I was delighted to see that the VM booted off the new image without a destroy / create cycle.
* I couldn't find a RHEL image but read that Oracle Linux is compatible.  Oracle Linux 9.7 
* Project stats:
  * Start: 2026-02-09
  * Functional: 2026-02-09
  * Number of Jenkins builds to success: 68
  * Hurdles: 
    * Non-default networking - dns_label.
    * Locating a compatible shape and image
