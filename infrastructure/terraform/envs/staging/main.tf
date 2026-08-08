# Module is used to define things in one place
# and achieve DRY
module "vm" {
  source = "../../modules/openstack_vm"

  # Renamed from "staging-docker": this OpenStack tenant is shared with the
  # upstream six7-click-n-deploy project, whose pipeline manages a VM of that
  # name. The module derives the keypair as "${name}-key", so a shared name
  # collides on both the instance and the keypair.
  name         = "staging-dhbw-appstore"
  image        = "Ubuntu 22.04"
  flavor       = "gp1.large"
  public_key   = var.ssh_public_key
  network_name = "DHBW"

  # No public floating-IP pool is usable from off-campus on this OpenStack;
  # deploy reaches the VM via its fixed IP on the network (requires the
  # operator to be in the network / a full-tunnel VPN). Flip to true and set
  # floating_ip_pool when a routable pool is available.
  assign_floating_ip = false

  # Referencing the resource rather than a bare name gives Terraform the
  # dependency, so the group and its rules exist before the instance is built.
  security_groups = ["default", openstack_networking_secgroup_v2.appstore_deploy.name]

  docker_data_volume_size_gb = 0

  metadata = {
    env  = "staging"
    role = "docker"
  }
}

output "vm_ip" {
  value = module.vm.vm_ip
}